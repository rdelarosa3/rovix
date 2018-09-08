Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'test#index'
  devise_for :users, controllers: {sessions: 'users/sessions',registrations:'users/registrations'}

  
  resources :search 
  get 'users/profile' => 'search#show' , :as => "user_profile"
  
  resources :watchlist 
  get 'search/destroy' => 'watchlist#destroy', :as => "destroy_watchlist"

end
 
