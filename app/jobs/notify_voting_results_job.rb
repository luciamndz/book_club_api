class NotifyVotingResultsJob < ApplicationJob
  queue_as :default

  def perform(voting_round_id)
    voting_round = VotingRound.includes(
      :winner,
      book_club: { book_club_members: :user }
    ).find(voting_round_id)

    return unless voting_round.status_finished?
    return unless voting_round.winner

    book_club = voting_round.book_club
    winner = voting_round.winner
    vote_count = voting_round.votes.count

    book_club.book_club_members.each do |member|
      BookClubMailer.voting_results(member.user, book_club, winner, vote_count).deliver_later
    end
  end
end
