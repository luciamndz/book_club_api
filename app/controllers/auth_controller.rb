class AuthController < ApplicationController
  # Skip authentication for login
  skip_before_action :authenticate_request!, only: [:login]

  def login
    user = User.find_by(email: auth_params[:email]&.downcase)

    # authenticate() is provided by has_secure_password
    # It hashes the plain password and compares with password_digest
    if user&.authenticate(auth_params[:password])
      token = JwtService.encode(user_id: user.id)
      render json: {
        token: token,
        user: { id: user.id, name: user.name, email: user.email }
      }, status: :ok
    else
      render json: {error: "Invalid email or password"}, status: :unauthorized
    end
  end

  # DELETE /auth/logout
  # JWT is stateless — we can't "invalidate" a token server-side
  # (unless you implement a token blocklist, which is advanced).
  # The front end is responsible for deleting the token.
  # This endpoint is a clean hook for any server-side logout logic later.
  def logout
    render json: {message: "Logged out successfully"}, status: :ok
  end

  def auth_params
    params.require(:auth).permit(:email, :password)
  end
end
