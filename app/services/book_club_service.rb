class BookClubService
    def initialize(user:, book_club: nil)
        @user = user
        @book_club = book_club
    end

    def create(params)
        book_club = BookClub.new(params)

        unless book_club.save
            return failure(book_club.errors.full_messages.join(","))
        end

        BookClubMember.create!(
            user: @user,
            book_club: book_club,
            role: "admin"
        )

        success(book_club)
    end

    def show
        current_book_club_member = BookClubMember.find_by(user: @user, book_club: @book_club)

        unless current_book_club_member
            return failure("User is not a member of this club")
        end

        success({
            book_club: @book_club,
            members: @book_club.book_club_members.includes(:user),
            current_book_club_member: current_book_club_member
        })
    end

    def join
        existing = BookClubMember.find_by(user: @user, book_club: @book_club)

        if existing
            return failure("User already a member of this club")
        end

        current_book_club_member = BookClubMember.create!(
            user: @user,
            book_club: @book_club,
            role: "member"
        )

        success(current_book_club_member)
    end

    def destroy
        current_book_club_member = BookClubMember.find_by(user: @user, book_club: @book_club)
        unless current_book_club_member&.role == "admin"
            return failure("User is not an admin of this club")
        end

        # The book club can only be deleted when the book club member is deleted as well.
        current_book_club_member.destroy 

        success(nil)
    end

    private

    def success(payload)
        ServiceResult.new(success: true, payload: payload)
    end

    def failure(errors)
        ServiceResult.new(success: false, errors: errors)
    end
end
