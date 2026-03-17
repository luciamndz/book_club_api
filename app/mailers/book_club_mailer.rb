class BookClubMailer < ApplicationMailer
  def voting_results(user, book_club, winner, vote_count)
    @user = user
    @book_club = book_club
    @winner = winner
    @vote_count = vote_count

    mail(
      to: @user.email,
      subject: "📚 #{@book_club.name} — Voting results are in!"
    )
  end
end
