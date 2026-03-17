class BookClub < ApplicationRecord
    has_many :book_club_members, dependent: :destroy
    has_many :users, through: :book_club_members
    has_many :books, dependent: :destroy
    has_many :voting_rounds, dependent: :destroy
    
    validates :name, presence: true
    validates :description, presence: true
    validates :status, inclusion: { in: %w[active inactive] }

    enum :status, {
        active: "active",
        inactive: "inactive"
    }, prefix: true

    after_initialize :set_default_status, if: :new_record?

    def set_default_status
        self.status ||= "active"
    end
end