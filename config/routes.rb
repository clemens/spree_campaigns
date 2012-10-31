Spree::Core::Engine.routes.prepend do
  namespace :admin do
    resources :campaigns
  end
end
