class UsersController < ApplicationController
  skip_before_action :authenticate_request!, only: [:create]
  
  def create
    user = User.new(user_params)

    if user.save
      token = JwtService.encode(user_id: user.id)
      render json: {
        token: token,
        user: {
          id: user.id,
          name: user.name,
          email: user.email
        }
      }, status: :created
    else
      render json: {errors: user.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def me
    render json: {
      user: {
        id: current_user.id,
        name: current_user.name,
        email: current_user.email
      }
    }, status: :ok
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
