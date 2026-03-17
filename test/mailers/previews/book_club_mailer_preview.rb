# Preview all emails at http://localhost:3000/rails/mailers/book_club_mailer
class BookClubMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/book_club_mailer/voting_results
  def voting_results
    BookClubMailer.voting_results
  end
end
