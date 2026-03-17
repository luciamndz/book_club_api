class BookClubsController < ApplicationController
  before_action :set_book_club, only: [:show, :join, :destroy]

  # GET /book_clubs - Returns ALL book clubs with the current user's membership status
  def index
    book_clubs = BookClub.includes(:book_club_members).all

    render json: book_clubs.map{ |club|
      current_book_club_member = club.book_club_members.find { |member| member.user_id == current_user.id }
      {
        id: club.id,
        name: club.name,
        description: club.description,
        status: club.status,
        member_count: club.book_club_members.size,
        current_user_role: current_book_club_member&.role,
        owner: current_book_club_member&.user&.name
      }
    }, status: :ok
  end

  def show
    result = BookClubService.new(user: current_user, book_club: @book_club).show

    if result.success?
      render json: serialize_show(result.payload), status: :ok
    else
      render json: { errors: result.errors }, status: :forbidden
    end
  end

  # POST /book_clubs Creates a club and makes the creator the admin
  def create
    result = BookClubService.new(user: current_user).create(book_club_params)

    if result.success?
      render json: serialize(result.payload, "admin"), status: :created
    else
      render json: { errors: result.errors }, status: :unprocessable_entity
    end
  end

  # POST /book_clubs/:id/join - Joins a book club
  def join
    result = BookClubService.new(user: current_user, book_club: @book_club).join

    if result.success?
      render json: serialize(@book_club, result.payload.role), status: :ok
    else
      render json: { errors: result.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /book_clubs/:id - Deletes a book club
  def destroy
    result = BookClubService.new(user: current_user, book_club: @book_club).destroy

    if result.success?
      render json: { message: "Book club deleted successfully" }, status: :ok
    else
      render json: { errors: result.errors }, status: :forbidden
    end
  end

  private

  def set_book_club
    @book_club = BookClub.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { errors: "Book club not found" }, status: :not_found
  end

  def book_club_params
    params.require(:book_club).permit(:name, :description)
  end

  def serialize(book_club, role)
    {
      id: book_club.id,
      name: book_club.name,
      description: book_club.description,
      status: book_club.status,
      member_count: book_club.book_club_members.count,
      current_user_role: role
    }
  end

  def serialize_show(payload)
    {
      book_club: {
        id: payload[:book_club].id,
        name: payload[:book_club].name,
        description: payload[:book_club].description,
        status: payload[:book_club].status,
        member_count: payload[:book_club].book_club_members.count,
        current_user_role: payload[:current_book_club_member].role
      },
      members: payload[:members].map { |member| {
        id: member.id,
        role: member.role,
        user: {
          id: member.user.id,
          name: member.user.name,
          email: member.user.email
        }
      } },
    }
  end

end