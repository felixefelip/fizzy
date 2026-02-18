# rbs_inline: enabled

class Notification < ApplicationRecord
  include PushNotifiable

  belongs_to :account, default: -> { user.account }
  belongs_to :user
  belongs_to :creator, class_name: "User"
  belongs_to :source, polymorphic: true
  belongs_to :card

  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :ordered, -> { order(read_at: :desc, updated_at: :desc) }
  scope :preloaded, -> { preload(:card, :creator, :account, source: [ :board, :creator, { eventable: [ :closure, :board, :assignments ] } ]) }

  before_validation :set_card
  after_create :bundle
  after_update :bundle, if: :source_id_previously_changed?

  after_create_commit  -> { broadcast_prepend_later_to user, :notifications, target: "notifications" }
  after_update_commit  -> { broadcast_update }
  after_destroy_commit -> { broadcast_remove_to user, :notifications }

  delegate :notifiable_target, to: :source

  class << self
    #: -> void
    def read_all
      all.each(&:read)
    end

    #: -> void
    def unread_all
      all.each(&:unread)
    end
  end

  #: -> void
  def read
    update!(read_at: Time.current, unread_count: 0)
  end

  #: -> void
  def unread
    update!(read_at: nil, unread_count: 1)
  end

  #: -> bool
  def read?
    read_at.present?
  end

  private
    #: -> void
    def set_card
      self.card = source.card
    end

    #: -> void
    def bundle
      # problema do design de tipos do activerecord para pensarmos aqui
      user.bundle(self) if user.settings.bundling_emails?
    end

    #: -> void
    def broadcast_update
      if read?
        broadcast_remove_to(user, :notifications)
      else
        broadcast_prepend_later_to(user, :notifications, target: "notifications")
      end
    end
end
