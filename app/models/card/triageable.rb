# rbs_inline: enabled

module Card::Triageable
  extend ActiveSupport::Concern

  # @type self: singleton(Card) & singleton(Card::Triageable)
  # @type instance: Card & Card::Triageable

  included do
    belongs_to :column, optional: true, touch: true

    scope :awaiting_triage, -> { active.where.missing(:column) }
    scope :triaged, -> { active.joins(:column) }
  end

  #: -> bool
  def triaged?
    active? && column.present?
  end

  #: -> bool
  def awaiting_triage?
    active? && !triaged?
  end

  #: (Column) -> void
  def triage_into(column)
    raise "The column must belong to the card board" unless board == column.board

    transaction do
      resume
      update! column: column
      track_event "triaged", particulars: { column: column.name }
    end
  end

  #: (?skip_event: bool) -> void
  def send_back_to_triage(skip_event: false)
    transaction do
      resume
      update! column: nil
      track_event "sent_back_to_triage" unless skip_event
    end
  end
end
