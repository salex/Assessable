Assessable::Engine.routes.draw do


  resources :assessments do
    member do
      post :post
      get :clone
      get :display
    end
    collection do
      get :group
      get :clone_group
    end
    resources :questions, :only => [ :new] 
  end

  resources :questions, :only => [:show, :edit, :update, :destroy, :create] do
    resources :answers, :only => [ :new] 
    member do
      get :edit_answers
      get :clone
    end
  end
  resources :answers, :only => [:show, :edit, :update, :destroy, :create]
  
  root :to => "home#index"
  
end
