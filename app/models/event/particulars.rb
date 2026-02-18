# rbs_inline: enabled

module Event::Particulars
  extend ActiveSupport::Concern

  included do
    store_accessor :particulars, :assignee_ids
  end

  #: -> User::ActiveRecord_Relation
  def assignees
    @assignees ||= User.where id: assignee_ids
  end
end
