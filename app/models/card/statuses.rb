# rbs_inline: enabled

module Card::Statuses
  extend ActiveSupport::Concern

  # @type self: singleton(Card) & singleton(Card::Statuses)
  # @type instance: Card & Card::Statuses

  included do
    enum :status, %w[ drafted published ].index_by(&:itself)

    attr_reader :initial_status #: ::ActiveSupport::StringInquirer?

    before_save :update_created_at_on_publication
    before_save :remember_initial_status
    after_create -> { track_event :published }, if: :published?

    scope :published_or_drafted_by, ->(user) { where(status: :published).or(where(status: :drafted, creator: user)) }
  end

  #: -> void
  def publish
    transaction do
      published!
      track_event :published
    end
  end

  #: -> bool
  def was_just_published?
    # status_in_database deveria não ser nilable, pois tem valor default no banco de dados e o Rails atribui esse valor mesmo para new records.
    initial_status&.drafted? && status_in_database.inquiry.published?
  end

  private
    #: -> void
    def update_created_at_on_publication
      if will_save_change_to_status? && status_in_database.inquiry.drafted?
        self.created_at = Time.current
      end
    end

    # So that we can check it in callbacks when other operations in the transaction clean the changes.
    #: -> void
    def remember_initial_status
      if will_save_change_to_status?
        @initial_status ||= status_in_database.to_s.inquiry
      end
    end
end
