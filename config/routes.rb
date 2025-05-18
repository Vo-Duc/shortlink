Rails.application.routes.draw do
  root to: 'application#index'

  namespace :api do
    namespace :v1 do
      post 'encode', to: 'short_links#encode'
      post 'decode', to: 'short_links#decode'
    end
  end

  get '/:short_url', to: 'application#redirect'

  get "up" => "rails/health#show", as: :rails_health_check
end
