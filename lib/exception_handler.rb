module ExceptionHandler
    # Custom error classes, map to a HTTP status code
    class AuthenticationError < StandardError; end
    class InvalidToken < StandardError; end
    class ExpiredSignature < StandardError; end
    class MissingToken < StandardError; end
end
