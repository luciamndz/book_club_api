class VotesController < ApplicationController
    before_action :set_book_club
    before_action :set_voting_round

    # POST /book_clubs/:book_club_id/voting_rounds/:voting_round_id/votes
    def create
        result = VoteService.new(user: current_user, book_club: @book_club, voting_round: @voting_round).cast(params[:book_id])
        
        if result.success?
            render json: { message: "Vote cast successfully" }, status: :created
        else
            render json: { errors: result.errors }, status: :unprocessable_entity
        end
    end

    # POST /book_clubs/:book_club_id/voting_rounds/:voting_round_id/submit_book
    def submit_book 
        result = VoteService.new(user: current_user, book_club: @book_club, voting_round: @voting_round).submit_book(params[:book_id])

        if result.success?
            render json: { message: "Book submitted successfully" }, status: :created
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
        @voting_round = @book_club.voting_rounds.find(params[:voting_round_id])
    rescue ActiveRecord::RecordNotFound
        render json: { errors: "Voting round not found" }, status: :not_found
    end
end