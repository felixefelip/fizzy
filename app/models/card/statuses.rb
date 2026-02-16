# rbs_inline: enabled

module Card::Statuses
  extend ActiveSupport::Concern

  # @type self: singleton(Card) & singleton(Card::Statuses)
  # @type instance: Card & Card::Statuses

  included do
    enum :status, %w[ drafted published ].index_by(&:itself)

    before_save :mark_if_just_published
    after_create -> { track_event :published }, if: :published?
  end

  attr_accessor :was_just_published
  alias_method :was_just_published?, :was_just_published

  #: -> void
  def publish
    transaction do
      self.created_at = Time.current
      published!
      track_event :published
    end
  end

  private
    #: -> void
    def mark_if_just_published
      self.was_just_published = true if published? && status_changed?
    end
end
