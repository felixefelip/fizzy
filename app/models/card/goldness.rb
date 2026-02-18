class Card::Goldness < ApplicationRecord
  belongs_to :account, default: -> do
    # @type self: Card::Goldness
    card.account
  end
  belongs_to :card, touch: true
end
