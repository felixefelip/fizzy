# rbs_inline: enabled

module Card::Closeable
  extend ActiveSupport::Concern

  # @rbs!
  #    extend _ActiveRecord_Relation_ClassMethods[::Card, ::Card::ActiveRecord_Relation, ::String]
  #
  #    def closure: -> Closure?
  #
  #    def self.closed: -> Card::ActiveRecord_Relation
  #    def self.open: -> Card::ActiveRecord_Relation

  included do
    # @type self: singleton(Card)

    has_one :closure, dependent: :destroy

    scope :closed, -> { joins(:closure) }
    scope :open, -> { where.missing(:closure) }

    scope :recently_closed_first, -> { closed.order("closures.created_at": :desc) }
    scope :closed_at_window, ->(window) { closed.where("closures.created_at": window) }
    scope :closed_by, ->(users) { closed.where("closures.user_id": Array(users)) }
  end

  def closed?
    closure.present?
  end

  def open?
    !closed?
  end

  def closed_by
    closure&.user
  end

  def closed_at
    closure&.created_at
  end

  def close(user: Current.user)
    unless closed?
      transaction do
        create_closure! user: user
        track_event :closed, creator: user
      end
    end
  end

  def reopen(user: Current.user)
    if closed?
      transaction do
        closure&.destroy
        track_event :reopened, creator: user
      end
    end
  end
end
