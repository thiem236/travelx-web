Rails.application.routes.draw do

  root :to => 'home#index'
  get 'home/index',:to => 'home#index'
  devise_for :admin_users
  get '/apple-app-site-association', :to => "home#apple_app_site"

  authenticate :admin_user do
    mount Sidekiq::Web => '/sidekiq'
  end
  # devise_for :users
  namespace :admin do
    resources :dashboard
    resources :users
    resources :trips do
      member do
        delete 'remove_user/:user_id', to: "trips#remove_user", as: 'remove_user_trip'
        put 'add_user/:user_id', to: "trips#add_user", as: 'add_user_trip'
      end
    end
    # resources :cities
    resources :notifications

    root to: "users#index"
  end

  get 'apidocs' => redirect('/swagger/dist/index.html?url=/apidocs/api-docs.json')
  mount_devise_token_auth_for 'User', at: 'api/v1/auth',controllers: {
      omniauth_callbacks: 'api/v1/omniauth_callbacks',
      registrations: 'api/v1/registrations',
      sessions: 'api/v1/sessions',
      passwords: 'api/v1/passwords'
  }

  # get 'passwords/edit'
  resources :passwords, only: [:edit, :update]
  namespace :api do
    scope defaults: { format: 'json' } do
      api_version(module: 'V1', path: {value: 'v1'}) do
        devise_scope :user do
          post 'passwords/check_code', to: 'passwords#check_code'
        end
        resources :users, only: [:index, :show] do
          collection do
            patch :update_profile
            post :verify_register
            post :add_friend
            post :cancel_request
            post :accept_friend
            delete :ignore_friend
            get :trip_list
            get :friend_list
            put :delete_friend
            get :friends_request
            post :get_user_by_contact
            post :get_user_by_fb
            post :update_device_token
            post :update_badge
            get :check_user_by_fb
          end

        end
        resources :trip_images, only: [:index,:update, :destroy, :show] do
          member do
            post :user_like
            post :add_comment
          end
        end

        resources :trips do
          # resources :posts
          resources :trip_images
          resources :cities, only: [:index]
          collection do
            get :get_trip_invited
            get :get_trip_accepted
            get :get_trip_invited
            get :list_trip_of_friend
          end
          member do
            get :list_image
            get :get_friend_trip
            get :list_detail_by_country
            put :ignored_trip
            put :accepted_trip
            put :invite_trip
          end
          resources :todo_list do
            collection do
              get :show_trip_id
            end
            member do
              patch :update_status
            end
          end
        end
        resources :notifications do
          collection do
            get :count_notification
            get :count_friend_noti
            put :update_read_all
            put :update_read_all_friend_noti
            put :clear_notification
          end
        end
        resources :cities do
          member do
            post :user_like
            post :add_comment
          end
          resources :comments
        end
        resources :invites do
          collection do
            post :invite_all
          end
        end
        resources :activities
        resources :stamps do
          collection do
            post :create_public_stamp
            get :public_stamps
          end
        end

        resources :contacts,only: [:index] do
          collection do
            post :syn_user_by_contact
          end
        end
        get 'countries/list_by_trip_friend', to: 'countries#list_by_trip_friend'
        get 'countries/list_by_my_trip', to: 'countries#list_by_my_trip'
        get 'countries/list_country_of_user', to: 'countries#list_country_of_user'
        get 'countries/list_by_trip_of_user', to: 'countries#list_by_trip_of_user'
        # resources :sessions, only: [:create, :destroy]

      end
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
