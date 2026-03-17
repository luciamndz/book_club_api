class BookService
    def initialize(user:, book_club:, book: nil)
        @user = user
        @book_club = book_club
        @book = book
    end

    def index
        books = @book_club.books.includes(:cover_attachment)
        success(books)
    end

    def create(params)
       # Find current member in this book club
       current_book_club_member = BookClubMember.find_by(user: @user, book_club: @book_club)

       unless current_book_club_member
        return failure("You are not a member of this book club")
       end

       book = @book_club.books.build(
        title: params[:title],
        author: params[:author],
        genre: params[:genre],
        synopsis: params[:synopsis],
        submitted_by: current_book_club_member
       )

       # Attach cover if provided
       book.cover.attach(params[:cover]) if params[:cover].present?

       if book.save
        success(book)
       else
        failure(book.errors.full_messages.join(","))
       end
    end

    def destroy
        current_book_club_member = BookClubMember.find_by(user: @user, book_club: @book_club)

        unless can_delete?(current_book_club_member)
            return failure("You are not authorized to delete this book")
        end

        @book.destroy
        success(nil)
    end

    private

    def can_delete?(current_book_club_member)
        return false unless current_book_club_member
        current_book_club_member.role_admin? || @book.submitted_by_id == current_book_club_member.id
    end

    def success(payload)
        ServiceResult.new(success: true, payload: payload)
    end

    def failure(errors)
        ServiceResult.new(success: false, errors: errors)
    end
end