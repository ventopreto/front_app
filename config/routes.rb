Rails.application.routes.draw do
  devise_for :users, controllers: {omniauth_callbacks: "users/omniauth_callbacks",
                                   sessions: "users/sessions",
                                   registrations: "users/registrations"}

  root to: "home#index"
  namespace :users do
    resources :policy, only: [:new, :create, :index]
    resources :payments
  end
end
