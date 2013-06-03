Rails.application.routes.draw do

  resources :instructors


  resources :model_assessors do
    member do
      get :new_assessor
    end
  end

  resources :stages, only: [:index,:show] do
    member do
      get :new_assessor
    end
    collection do
      get :apply
      get :evaluate
      get :survey
      get :score
    end
  end
  
  resources :take, only: :show do
    member do
      get :section
      get :apply
      get :score
      get :evaluate
      get :survey
      put :post
      get :complete
      put :finish
      get :cancel
    end
  end
  
  resources :assessors, :except => :new do
    resources :assessor_sections, :only => :new
    member do
      get :rescore
      get :display
      post :post
    end
  end

  resources :users


  resources :scores


  resources :assessor_sections, :except => :new do
    member do
      post :search
      get :list
      get :rescore
    end
  end




  resources :surveyors do
    member do
      post :post
      get :display
    end
  end


  mount Assessable::Engine => "/assessable"
  root :to => "home#index"
  
end
