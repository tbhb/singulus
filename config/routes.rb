# frozen_string_literal: true

require 'sidekiq/web'
require 'sidekiq_unique_jobs/web'

Rails.application.routes.draw do # rubocop:disable Metrics/BlockLength
  devise_for :users, only: %i[sessions], path: '',
                     path_names: { sign_in: 'login', sign_out: 'logout' }
  get '/unlock', to: 'devise/unlocks#show', as: :user_unlock

  use_doorkeeper

  scope '/indieauth', as: :indieauth, format: false do
    resource(
      :authorization,
      path: 'authorize',
      only: %i[create destroy],
      controller: 'indieauth/authorizations'
    ) do
      get '/native', action: :show, on: :member
      get '/', action: :new, on: :member
    end

    resource(
      :token,
      path: 'token',
      only: %i[create show],
      controller: 'indieauth/tokens'
    )
  end

  get '/health', to: 'health#show', as: :health, format: false

  get '/micropub', to: 'micropub/queries#show', as: :micropub, format: false
  post '/micropub', to: 'micropub/posts#create', format: false
  post '/micropub/media', to: 'micropub/media#create', as: :micropub_media, format: false

  scope format: false do
    resources :photos
    resources :posts
  end

  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
  end

  root to: 'home#index'
end
