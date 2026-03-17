class VotingRound < ApplicationRecord
    belongs_to :book_club
    belongs_to :created_by, class_name: "BookClubMember", foreign_key: :book_club_member_id
    belongs_to :winner, class_name: "Book", foreign_key: :winner_id, optional: true

    has_many :votes, dependent: :destroy

    validates :status, inclusion: { in: %w[draft active finished] }
    validates :book_club_id, 
        uniqueness: { 
        conditions: -> { where(status: %w[draft active]) }, 
        message: "Already has an active or draft voting round" 
    }
    enum :status, {
        draft: "draft",
        active: "active",
        finished: "finished"
    }, prefix: true

    after_initialize :set_default_status, if: :new_record?

    private

    def set_default_status
        self.status ||= "draft"
    end
end