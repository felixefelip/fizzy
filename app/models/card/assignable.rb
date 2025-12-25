# rbs_inline: enabled

module Card::Assignable
  extend ActiveSupport::Concern

  # @rbs!
  #   def assignments: -> Assignment::ActiveRecord_Associations_CollectionProxy
  #   def assignees: -> User::ActiveRecord_Associations_CollectionProxy

  included do
    # @type self: singleton(Card)

    has_many :assignments, dependent: :delete_all
    has_many :assignees, through: :assignments

    scope :unassigned, -> { where.missing :assignments }
    scope :assigned_to, ->(users) { joins(:assignments).where(assignments: { assignee: users }).distinct }
    scope :assigned_by, ->(users) { joins(:assignments).where(assignments: { assigner: users }).distinct }
  end

  def toggle_assignment(user)
    assigned_to?(user) ? unassign(user) : assign(user)
  end

  def assigned_to?(user)
    assignments.any? { |a| a.assignee_id == user.id }
  end

  def assigned?
    assignments.any?
  end

  private
    def assign(user)
      assignments.create! assignee: user, assigner: Current.user
      watch_by user

      track_event :assigned, assignee_ids: [ user.id ]
    rescue ActiveRecord::RecordNotUnique
      # Already assigned
    end

    def unassign(user)
      destructions = assignments.destroy_by assignee: user
      track_event :unassigned, assignee_ids: [ user.id ] if destructions.any?
    end
end
