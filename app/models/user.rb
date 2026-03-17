class User < ApplicationRecord
    has_secure_password # Rails macro method that provides password hashing and validation
    has_many :book_club_members, dependent: :destroy
    has_many :book_clubs, through: :book_club_members

    validates :name, presence: true
    validates :email, presence: true, uniqueness: {case_sensitive: false}, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :password, presence: true, length: {minimum: 6}, if: -> { new_record? || !password.nil? }

    before_save :downcase_email

    private

    def downcase_email
        self.email = email.downcase
    end
end
