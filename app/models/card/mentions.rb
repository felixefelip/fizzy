# rbs_inline: enabled

module Card::Mentions
  extend ActiveSupport::Concern

  # @rbs!
  #   def published?: -> bool
  #   def was_just_published?: -> bool

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
