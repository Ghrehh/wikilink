Rails.application.routes.draw do
  root "searches#new"
  resources :searches
  resources :sites
end
