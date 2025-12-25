# rbs_inline: enabled

module Card::Colored
  extend ActiveSupport::Concern

  # @rbs!
  #   def column: -> Column?

  def color
    column&.color || Column::Colored::DEFAULT_COLOR
  end
end
