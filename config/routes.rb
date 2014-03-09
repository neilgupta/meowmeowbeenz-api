Meowmeowbeenz::Application.routes.draw do
  apipie

  resources :users, only: [:show, :create, :update] do
    post 'login', on: :collection
    get 'logout', 'search', on: :collection
    post 'give', on: :member
  end
end
