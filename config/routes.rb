Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'test#index'
  devise_for :users, controllers: {sessions: 'users/sessions',registrations:'users/registrations'}

  
  resources :search 
  get 'users/profile' => 'watchlist#show' , :as => "user_profile"
  
  resources :watchlist 
  get 'watchlist/destroy' => 'watchlist#destroy', :as => "destroy_watchlist"

end
 
