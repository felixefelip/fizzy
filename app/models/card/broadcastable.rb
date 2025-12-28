# rbs_inline: enabled

module Card::Broadcastable
  extend ActiveSupport::Concern

  # @type module: singleton(Card) & singleton(Card::Broadcastable)
  # @type instance: Card & Card::Broadcastable

  # @rbs!
  #    @preview_changed: bool

  included do
    broadcasts_refreshes

    before_update :remember_if_preview_changed
  end

  private
    #: -> void
    def remember_if_preview_changed
      @preview_changed ||= title_changed? || column_id_changed? || board_id_changed?
    end

    #: -> bool
    def preview_changed?
      @preview_changed
    end
end
