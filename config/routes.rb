Rails.application.routes.draw do

  root 'posts#index'

  resources :posts
  resources :witnesses do
    collection do
      get :updates
      get :votes
    end
  end

end
