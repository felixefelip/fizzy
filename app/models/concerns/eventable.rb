# rbs_inline: enabled

module Eventable
  extend ActiveSupport::Concern

  # @type self: singleton(ApplicationRecord) & singleton(Eventable)
  # @type instance: ApplicationRecord & Eventable

  included do
    has_many :events, as: :eventable, dependent: :destroy
  end

  #: (Symbol | String, ?creator: User, ?board: Board, **untyped) -> void
  def track_event(action, creator: Current.user, board: self.board, **particulars)
    if should_track_event?
      board.events.create!(action: "#{eventable_prefix}_#{action}", creator:, board:, eventable: self, particulars:)
    end
  end

  def event_was_created(event)
  end

  private
    #: -> bool
    def should_track_event?
      true
    end

    #: -> String
    def eventable_prefix
      self.class.name.demodulize.underscore
    end
end
