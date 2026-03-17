class Book < ApplicationRecord
    belongs_to :book_club
    belongs_to :submitted_by, class_name: "BookClubMember", optional: true
    has_many :votes, dependent: :destroy

    has_one_attached :cover

    validates :title, presence: true, uniqueness: { scope: :book_club_id }
    validates :author, presence: true
    validates :status, inclusion: { in: %w[created submitted selected] }
    enum :status, {
        created: "created",
        submitted: "submitted",
        selected: "selected"
    }, prefix: true

    after_initialize :set_default_status, if: :new_record?

    private

    def set_default_status
        self.status ||= "created"
    end

end
