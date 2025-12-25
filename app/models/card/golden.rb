# rbs_inline: enabled

module Card::Golden
  extend ActiveSupport::Concern

  # @rbs!
  #   def goldness: -> Card::Goldness?

  included do
    # @type self: singleton(Card)

    has_one :goldness, dependent: :destroy, class_name: "Card::Goldness"

    scope :golden, -> { joins(:goldness) }
    scope :with_golden_first, -> { left_outer_joins(:goldness).prepend_order("card_goldnesses.id IS NULL").preload(:goldness) }
  end

  #: -> bool
  def golden?
    goldness.present?
  end

  #: -> Card::Goldness?
  def gild
    create_goldness! unless golden?
  end

  #: -> bool?
  def ungild
    goldness&.destroy
  end
end
