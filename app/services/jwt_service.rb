class JwtService
    # The secret key to sign tokens
    SECRET_KEY = Rails.application.credentials.secret_key_base

    def self.encode(payload, expiration = 24.hours.from_now)
        # Add expiration to the payload
        payload[:exp] = expiration.to_i # JWT expects an integer timestamp

        JWT.encode(payload, SECRET_KEY, "HS256") # HS256 signing algorithm
    end

    def self.decode(token)
        # Returns an array [payload_hash, header_hash]
        decoded = JWT.decode(token, SECRET_KEY, true, algorithm: "HS256")
        # We only need the payload hash, so we return the first element
        HashWithIndifferentAccess.new(decoded[0])
    rescue JWT::DecodeError => e
        raise ExceptionHandler::InvalidToken, e.message
    rescue JWT::ExpiredSignature
        raise ExceptionHandler::ExpiredSignature, "Token has expired"
    end
end