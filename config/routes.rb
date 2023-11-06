Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  resource :transaction, only: [:create]
  get "merchants/map-ynab" => "merchants#map_ynab", as: :map_ynab_merchants
  patch "merchants/ynab-mapping" => "merchants#update_ynab_mapping", as: :update_ynab_mapping_merchants

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
