# rbs_inline: enabled

module Card::Mentions
  extend ActiveSupport::Concern

  # @type self: singleton(Card) & singleton(Card::Mentions)
  # @type instance: Card & Card::Mentions

  included do
    include ::Mentions

    #: -> bool
    def mentionable?
      published?
    end

    #: -> bool
    def should_check_mentions?
      was_just_published?
    end
  end
end
