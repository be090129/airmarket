Rails.application.routes.draw do

  root 'pages#home'

  devise_for :users, controllers: {
     sessions: 'users/sessions',
     registrations: 'users/registrations'
  }

  resources :listings do
    resources :orders do
      resources :messages
    end

  end


  resources :images

  get "listings-list" => "listings#index2"

  #PAGE STATIC

  get "about" => "pages#about"
  get "cancellation" => "pages#cancellation"
  get "terms-of-service" => "pages#termsofservice"

  #BACK OFFICE FRONT

  get "manage-listings" => "listings#managelistings"
  get 'manage-listings/:id' => 'listings#edit', as: :modification
  get 'sales' => "orders#sales"
  get 'purchases' => "orders#purchases"

  #PAYIN

  get 'orders/:id/payin' => 'orders#payin', as: :payin
  get 'orders/:id/directpayin' => 'orders#dopayin', as: :directpayin
  get 'orders/:id/changecard' => 'orders#changecard', as: :changecard
  get 'orders/:id/payin_ok' => 'orders#payin_ok', as: :payin_ok

  get 'orders/:id/payoutseller' => 'orders#payoutseller', as: :payoutseller
  patch 'orders/:id/dopayout' => 'orders#dopayout', as: :dopayout

  #BACK OFFICE ADMIN

  namespace :admin do
    root to: "admin#home"
    resources :orders
    resources :listings
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

end
