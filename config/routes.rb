Rails.application.routes.draw do
  namespace :api do
    get 'hour' => "main#hour"
    get 'listens' => "listens#index"
    get 'sessions' => "main#sessions"
  end

  root to:"home#dashboard"
end
