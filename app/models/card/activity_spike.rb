class Card::ActivitySpike < ApplicationRecord
  belongs_to :account, default: -> do
    # @type self: Card::ActivitySpike
    card.account
  end

  belongs_to :card, touch: true
end
