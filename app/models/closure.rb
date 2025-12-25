class Closure < ApplicationRecord
  belongs_to :account, default: -> do
    # @type self: Closure
    card.account
  end
  belongs_to :card, touch: true
  belongs_to :user, optional: true
end
