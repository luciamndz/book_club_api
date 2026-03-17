class VotingRoundService
    def initialize(user:, book_club:, voting_round: nil)
        @user = user
        @book_club = book_club
        @voting_round = voting_round
    end

    # POST /book_clubs/:id/voting_rounds (Admin only)
    def create
        current_book_club_member = find_member
        return failure("You are not a member of this club") unless current_book_club_member
        return failure("You are not an admin of this club") unless current_book_club_member.role_admin?

        # Only one draft/active round allowed per club
        existing = @book_club.voting_rounds.where(status: %w[draft active]).first
        return failure("This club already has an active voting round") if existing

        voting_round = VotingRound.new(
            book_club: @book_club,
            created_by: current_book_club_member,
            status: "draft"
        )

        if voting_round.save
            success(voting_round)
        else
            failure(voting_round.errors.full_messages.join(","))
        end
    end

    # PATCH /book_clubs/:id/voting_rounds/:voting_round_id/open (Admin sets duration and opens the round)
    def open(params)
        current_book_club_member = find_member
        return failure("Only admins can open voting") unless current_book_club_member&.role_admin?
        return failure("Round is not in draft") unless @voting_round.status_draft?

        # Must have at least one submitted book to open voting
        submitted_books = @book_club.books.where(status: "submitted")
        return failure("One book must be submitted to open voting") if submitted_books.empty?

        if @voting_round.update(
            starts_at: params[:starts_at],
            ends_at: params[:ends_at],
            status: "active"
        )
            success(@voting_round)
        else
            failure(@voting_round.errors.full_messages.join(","))
        end
    end

    # PATCH /book_clubs/:id/voting_rounds/:voting_round_id/finish (Finishes round and determine winners)
    def finish
        current_book_club_member = find_member
        return failure("Only admins can finish a voting round") unless current_book_club_member&.role_admin?
        return failure("Round is not active") unless @voting_round.status_active?

        winner = determine_winner
        return failure("No winner found") unless winner

        winner.update!(status: "selected")

        @book_club.books
            .where(status: "submitted")
            .where.not(id: winner.id)
            .update_all(status: "created")

        @voting_round.update!(status: "finished", winner: winner)

        # TODO: trigger Sidekiq job for email notification here
        success(@voting_round)
    end

    private

    def find_member
        BookClubMember.find_by(user: @user, book_club: @book_club)
    end

    def determine_winner
        # Count votes per book and find the one with most votes
        # In case of tie, pick the one voted first
        winning_vote = @voting_round.votes
                                    .select("book_id, count(*) as vote_count")
                                    .group(:book_id)
                                    .order("vote_count DESC, MIN(created_at) ASC")
                                    .first
        Book.find_by(id: winning_vote&.book_id)
    end

    def success(payload)
        ServiceResult.new(success: true, payload: payload)
    end

    def failure(errors)
        ServiceResult.new(success: false, errors: errors)
    end
end