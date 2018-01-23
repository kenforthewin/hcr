Rails.application.routes.draw do
  get 'scans/new', to: 'scans#new'
  get 'scans/:uuid', to: 'scans#show', as: :scan
  post '/scans', to: 'scans#create'

  root 'scans#new'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
