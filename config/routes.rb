require "sidekiq/web"

Sidekiq::Web.use ActionDispatch::Cookies
Sidekiq::Web.use ActionDispatch::Session::CookieStore, key: "_interop_session"

Rails.application.routes.draw do
  mount Sidekiq::Web => "/sidekiq"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Auth routes
  post "/auth/login", to: "auth#login"
  delete "/auth/logout", to: "auth#logout"

  # User routes
  post "/users", to: "users#create"
  get "/users/me", to: "users#me"

  # Book club routes
  get "/book_clubs", to: "book_clubs#index"
  post "/book_clubs", to: "book_clubs#create"
  get "/book_clubs/:id", to: "book_clubs#show"
  post "/book_clubs/:id/join", to: "book_clubs#join"
  delete "/book_clubs/:id", to: "book_clubs#destroy"

  # Book routes
  get "/book_clubs/:book_club_id/books", to: "books#index"
  post "/book_clubs/:book_club_id/books", to: "books#create"
  delete "/book_clubs/:book_club_id/books/:id", to: "books#destroy"

  # Voting round routes
  get   "/book_clubs/:book_club_id/voting_rounds/current",     to: "voting_rounds#current"
  post  "/book_clubs/:book_club_id/voting_rounds",             to: "voting_rounds#create"
  patch "/book_clubs/:book_club_id/voting_rounds/:id/open",    to: "voting_rounds#open"
  patch "/book_clubs/:book_club_id/voting_rounds/:id/finish",  to: "voting_rounds#finish"

  # Vote routes
  post "/book_clubs/:book_club_id/voting_rounds/:voting_round_id/votes",       to: "votes#create"
  post "/book_clubs/:book_club_id/voting_rounds/:voting_round_id/submit_book", to: "votes#submit_book"
end
