Rails.application.routes.draw do
  root 'test#index'
  devise_for :users, controllers: {sessions: 'users/sessions',registrations:'users/registrations'}
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :search
  resources :watchlist
  get 'search/destroy' => 'watchlist#destroy', :as => "destroy_watchlist"

end
