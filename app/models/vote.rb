class Vote < ApplicationRecord
    belongs_to :voting_round
    belongs_to :book
    belongs_to :cast_by, class_name: "BookClubMember", foreign_key: :book_club_member_id

    validates :book_club_member_id, 
        uniqueness: { 
            scope: :voting_round_id,
            message: "Already voted for this round"
        }
    validate :book_must_be_submitted

    private

    def book_must_be_submitted
        return unless book
        unless book&.status_submitted?
            errors.add(:book, "Book must be submitted to be voted on")
        end
    end
end