require "sidekiq/web"

Sidekiq::Web.use ActionDispatch::Cookies
Sidekiq::Web.use ActionDispatch::Session::CookieStore, key: "_interop_session"

Rails.application.routes.draw do
  mount Sidekiq::Web => "/sidekiq"
  get "up" => "rails/health#show", as: :rails_health_check

  # Auth routes
  post "/auth/login", to: "auth#login"
  delete "/auth/logout", to: "auth#logout"

  # User routes
  resources :users, only: [:create]

  # Book club routes
  resources :book_clubs, except: [:update, :destroy] do
    resources :books, only: [:index, :create, :destroy]
    resources :voting_rounds, except: [:index] do 
      resources :votes, only: [:create]
    end
  end
  
  post "/book_clubs/:id/join", to: "book_clubs#join"
  post "/book_clubs/:book_club_id/voting_rounds/:voting_round_id/submit_book", to: "votes#submit_book"
end
