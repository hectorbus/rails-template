Rails.application.routes.draw do
  resources :permissions
  resources :roles

  devise_for :users,
             controllers: {sessions: 'users/sessions',
                           confirmations: 'users/confirmations',
                           unlocks: 'users/unlocks',
                           registrations: 'users/registrations',
                           passwords: 'users/passwords',
                           password_expired: 'users/password_expired'},
             path: '/',
             path_names: {sign_in: 'login',
                          sign_out: 'logout'}

  devise_scope :user do
    authenticated :user do
      root 'home#index', as: :authenticated_root
    end

    unauthenticated do
      root 'users/sessions#new', as: :unauthenticated_root
    end

    authenticate :user do
      # Shows all users.
      get '/users', to: 'users/registrations#index', as: :user_registrations

      # Create new users.
      get '/users/new', to: 'users/registrations#new_user', as: :new_user
      post '/users', to: 'users/registrations#create_user', as: :create_user

      # Edit page for a user profile.
      get '/users/edit', to: 'users/registrations#edit', as: :edit_profile
      match '/users', to: 'users/registrations#update', as: :update_profile, via: [:patch, :put]

      # User image
      match '/users/:id/get_user_image', to: 'users/registrations#get_user_image', as: :get_user_image, via: [:patch, :put]

      # Edit page for all users.
      get '/users/:id/edit', to: 'users/registrations#edit_user', as: :edit_user
      match '/users/:id', to: 'users/registrations#update_user', as: :update_user, via: [:patch, :put]

      # Show page for a user.
      get '/users/:id', to: 'users/registrations#show', as: :user

      # Edit a user password.
      get '/users/:id/change_password', to: 'users/registrations#change_password', as: :change_password
      match 'save_password/:id', to: 'users/registrations#save_password', as: :save_password,
            via: [:patch, :put]

      # Destroys a user
      delete '/users/:id', to: 'users/registrations#destroy', as: :destroy_user_registration

      # Gets a JS response with all controller actions.
      get '/permissions/new/get_controller_actions', to: 'permissions#get_controller_actions', as: :get_controller_actions

      # Posts seed data from permissions in relation with their role.
      post '/permissions/generate_seeds', to: 'permissions#generate_seeds', as: :generate_seeds

      # Displays a role with every permission granted.
      get '/roles/:role_id/permissions', to: 'roles#role_permissions', as: :role_permissions

      # Creates a relationship between roles and permissions.
      post '/roles/:role_id/assign_permissions', to: 'roles#assign_permissions', as: :assign_permissions

      # Sets the language to spanish.
      get '/set_language/spanish'

      # Sets the language to english.
      get '/set_language/english'
    end
  end
end
