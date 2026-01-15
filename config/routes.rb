Rails.application.routes.draw do
  resource :cart, only: [ :show ]
  resources :cart_items, only: [ :create, :update, :destroy ]
  resource :session
  resources :passwords, param: :token
  root "landings#index"

  get "/about", to: "landings#about"
  get "/contact", to: "landings#contact"

  resource :checkout, only: [ :new, :create ] do
    member do
      get :payment_callback
    end
  end

  resources :orders, only: [ :index, :show ] do
    member do
      get :confirmation
    end
  end

  namespace :settings do
    resources :shipping_addresses
  end

  post "/razorpay/webhook", to: "checkouts#webhook"

  resources :products do
    member do
      delete :purge_image
    end
  end

  namespace :admin do
    root "dashboard#index"
    resources :orders, only: [ :index, :show, :update ] do
      collection do
        get :export
      end
    end
    resources :users, only: [ :index, :show ] do
      collection do
        get :export
      end
    end
    get "analytics", to: "dashboard#analytics"
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
