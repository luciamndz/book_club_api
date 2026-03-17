class VoteService
    def initialize(user:, book_club:, voting_round:)
        @user = user
        @book_club = book_club
        @voting_round = voting_round
    end

    # POST /book_clubs/:id/voting_rounds/:voting_round_id/votes (Member votes for a book)
    def cast(book_id)
        current_book_club_member = BookClubMember.find_by(user: @user, book_club: @book_club)

        return failure("You are not a member of this club") unless current_book_club_member
        return failure("Voting round is not active")        unless @voting_round.status_active?
        return failure("Voting has ended")                  if @voting_round.ends_at < Time.current

        already_voted = Vote.exists?(
            voting_round: @voting_round,
            book_club_member_id: current_book_club_member.id
        )
        return failure("You have already voted for this round") if already_voted

        book = @book_club.books.find_by(id: book_id)
        return failure("Book not found") unless book
        return failure("Book is not submitted") unless book.status_submitted?

        vote = Vote.create!(
            voting_round: @voting_round,
            cast_by: current_book_club_member,
            book: book
        )

        if vote.persisted?
            check_auto_finish
            success(vote)
        else
            failure(vote.errors.full_messages.join(","))
        end
    end

    # POST /book_clubs/:id/voting_rounds/:voting_round_id/submit_book
    def submit_book(book_id)
        current_book_club_member = BookClubMember.find_by(user: @user, book_club: @book_club)
        return failure("You are not a member of this club") unless current_book_club_member
        return failure("Round is not in draft")             unless @voting_round.status_draft?

        book = @book_club.books.find_by(id: book_id)
        return failure("Book not found") unless book
        return failure("Book is already submitted") if book.status_submitted?

        book.update!(status: "submitted", submitted_by: current_book_club_member)
        success(book)
    end

    private
    
    def check_auto_finish
        total_members = @book_club.book_club_members.count
        total_votes = @voting_round.votes.count

        if total_votes >= total_members
            VotingRoundService.new(user: @user, book_club: @book_club, voting_round: @voting_round).finish
        end
    end

    def success(payload)
        ServiceResult.new(success: true, payload: payload)
    end

    def failure(errors)
        ServiceResult.new(success: false, errors: errors)
    end
end