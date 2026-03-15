class ApplicationController < ActionController::API
    include ExceptionHandler

    before_action :authenticate_request!

    private

    def authenticate_request!
        @current_user = User.find(decoded_token[:user_id])
    rescue ActiveRecord::RecordNotFound
        render json: {error: "User not found"}, status: :unauthorized
    rescue ExceptionHandler::ExpiredSignature => e
        render json: {error: e.message}, status: :unauthorized
    rescue ExceptionHandler::InvalidToken, ExceptionHandler::ExpiredSignature => e
        render json: {error: e.message}, status: :unauthorized
    end

    def decoded_token
        token = extract_token_from_header
        JwtService.decode(token)
    end

    def extract_token_from_header
        # Header format: "Authorization: Bearer <token>"
        header = request.headers["Authorization"]
        raise ExceptionHandler::MissingToken, "Missing token" unless header

        # Split Bearer and grab token 
        header.split(" ").last
    end

    def current_user
        @current_user
    end

end
