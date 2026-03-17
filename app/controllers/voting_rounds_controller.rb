class VotingRoundsController < ApplicationController
    before_action :set_book_club
    before_action :set_voting_round, only: [:open, :finish]

    # GET /book_clubs/:book_club_id/voting_rounds/current
    def current 
        voting_round = @book_club.voting_rounds
        .where(status: %w[draft active])
        .includes(votes: :book)
        .first

        if voting_round
            render json: serialize(voting_round), status: :ok
        else
            render json: nil, status: :ok
        end
    end

    def create
        result = VotingRoundService.new(user: current_user, book_club: @book_club).create

        if result.success?
            render json: serialize(result.payload), status: :created
        else
            render json: { errors: result.errors }, status: :unprocessable_entity
        end
    end

    def open
        result = VotingRoundService.new(user: current_user, book_club: @book_club, voting_round: @voting_round).open(voting_round_params)

        if result.success?
            render json: serialize(result.payload), status: :ok
        else
            render json: { errors: result.errors }, status: :unprocessable_entity
        end
    end

    def finish
        result = VotingRoundService.new(user: current_user, book_club: @book_club, voting_round: @voting_round).finish

        if result.success?
            render json: serialize(result.payload), status: :ok
        else
            render json: { errors: result.errors }, status: :unprocessable_entity
        end
    end

    private

    def set_book_club
        @book_club = BookClub.find(params[:book_club_id])
    rescue ActiveRecord::RecordNotFound
        render json: { errors: "Book club not found" }, status: :not_found
    end

    def set_voting_round
        @voting_round = @book_club.voting_rounds.find(params[:id])
    rescue ActiveRecord::RecordNotFound
        render json: { errors: "Voting round not found" }, status: :not_found
    end

    def voting_round_params
        params.require(:voting_round).permit(:starts_at, :ends_at)
    end

    def serialize(voting_round)
        {
            id: voting_round.id,
            status: voting_round.status,
            starts_at: voting_round.starts_at,
            ends_at: voting_round.ends_at,
            updated_at: voting_round.updated_at,
            vote_count: voting_round.votes.size,
            user_has_voted: voting_round.votes.exists?(
                book_club_member_id: current_member_id(voting_round)
            ),
            winner: voting_round.winner ? {
                id: voting_round.winner.id,
                title: voting_round.winner.title,
                author: voting_round.winner.author,
                cover_url: voting_round.winner.cover.attached? ? url_for(voting_round.winner.cover) : nil
            } : nil
        }
    end

    def current_member_id(voting_round)
        BookClubMember.find_by(user: current_user, book_club: voting_round.book_club)&.id
    end
end
