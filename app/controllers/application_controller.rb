class ApplicationController < ActionController::API
  def current_user
    hmac_secret = Rails.application.credentials.dig(:API_KEY)
    token = request.headers["Authorization"].to_s.split(" ").last
    return unless token

    user_id = JWT.decode(token, hmac_secret, false, { algorithm: "HS256" }).first
    User.find(user_id)
  end
end
