class BooksController < ApplicationController
    before_action :set_book_club
    before_action :set_book, only: [:destroy]

    # GET /book_clubs/:book_club_id/books
    def index
        result = BookService.new(user: current_user, book_club: @book_club).index

        if result.success? 
            render json: result.payload.map { |book| serialize(book) }, status: :ok
        else
            render json: { errors: result.errors }, status: :forbidden
        end
    end

    # POST /book_clubs/:book_club_id/books
    def create
        result = BookService.new(user: current_user, book_club: @book_club).create(book_params)

        if result.success?
            render json: serialize(result.payload), status: :created
        else
            render json: { errors: result.errors }, status: :unprocessable_entity
        end
    end

    # DELETE /book_clubs/:book_club_id/books/:id
    def destroy
        result = BookService.new(user:current_user, book_club: @book_club, book: @book).destroy

        if result.success?
            render json: { message: "Book deleted successfully" }, status: :ok
        else
            render json: { errors: result.errors }, status: :forbidden
        end
    end

    private

    def set_book_club
        @book_club = BookClub.find(params[:book_club_id])
    rescue ActiveRecord::RecordNotFound
        render json: { errors: "Book club not found" }, status: :not_found
    end

    def set_book
        @book = @book_club.books.find(params[:id])
    rescue ActiveRecord::RecordNotFound
        render json: { errors: "Book not found" }, status: :not_found
    end

    def book_params
        params.require(:book).permit(:title, :author, :genre, :synopsis, :cover)
    end

    def serialize(book)
        {
            id: book.id,
            title: book.title,
            author: book.author,
            genre: book.genre,
            synopsis: book.synopsis,
            status: book.status,
            submitted_by: book.submitted_by_id,
            cover_url: book.cover.attached? ? url_for(book.cover) : nil
        }
    end
end