Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  resource :transaction, only: [:create]
  resource :session
  resource :registration
  resource :password_reset
  resource :password
  resources :merchants, only: [:index, :show]
  resources :tasks, only: [:index] do
      collection do
          post :sync_ynab_transactions
          post :sync_ynab_payees
          post :maintain_balances
      end
  end

  patch "merchants/ynab-mapping" => "merchants#update_ynab_mapping", as: :update_ynab_mapping_merchants
  patch "merchants/exclude_from_mapping" => "merchants#exclude_from_mapping", as: :exclude_from_merchants_mapping

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "main#index"
end
