class BookClubMember < ApplicationRecord
    belongs_to :user
    belongs_to :book_club
    has_many :submitted_books, class_name: "Book", foreign_key: :submitted_by_id
    has_many :voting_rounds, foreign_key: :book_club_member_id, dependent: :destroy
    has_many :votes, foreign_key: :book_club_member_id, dependent: :destroy

    validates :role, inclusion: { in: %w[admin member] }
    validates :user_id, uniqueness: { scope: :book_club_id, message: "User already belongs to this book club" }

    enum :role, {
        admin: "admin",
        member: "member"
    }, prefix: true

end