# rbs_inline: enabled

module Card::Multistep
  extend ActiveSupport::Concern

  included do
    # @type self: singleton(Card)
    has_many :steps, dependent: :destroy
  end
end
