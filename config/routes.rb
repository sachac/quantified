Home::Application.routes.draw do
  resources :contexts do
    member do
      get :start
      put :complete
    end
  end

  resources :measurement_logs

  resources :measurements
  resources :locations
  resources :stuff 
  resources :location_histories
  match 'stuff/log', :via => :post, :as => :log_stuff
  match 'menu' => 'home#menu', :as => :menu
  resources :days

  match 'csa_foods/bulk_update', :as => :bulk_update_csa_foods, :via => :post
  resources :csa_foods do
    collection do
      post :quick_entry 
    end
  end

  resources :foods

  devise_for :users, :path_prefix => 'd'
  resources :users

  resources :decision_logs

  resources :decisions
  resources :toronto_libraries
  resources :library_items do
    get :tag, :on => :collection
    get :current, :on => :collection
  end

  match 'clothing/bulk', :as => :clothing_bulk, :via => :post
  match 'library_items/bulk', :as => :library_item_bulk, :via => :post

  match 'time' => 'time#index'
  match 'time/graph(/:start(/:end))' => 'time#graph', :as => :time_graph
  match 'time/clock(/:start(/:end))' => 'time#clock', :as => :time_clock
  match 'time/refresh' => 'time#refresh_from_csv', :as => :refresh_from_csv, :via => :post
  match 'time/refresh' => 'time#refresh', :as => :refresh_time
  resources :clothing do
    get :autocomplete_clothing_name, :on => :collection
    get :analyze, :on => :collection, :as => :clothing_analysis
    get :graph, :on => :collection, :as => :clothing_graph
  end
  resources :clothing_logs
  match 'clothing_logs/by_date/:date' => 'clothing_logs#by_date', :as => :clothing_logs_by_date
  match 'clothing/tag/:id' => 'clothing#tag', :as => :clothing_by_tag
  match 'clothing/status/:status' => 'clothing#by_status', :as => :clothing_by_status
  match 'clothing/analyze/:start/:end' => 'clothing#analyze', :as => :clothing_analyze
  match 'library/update' => 'library#update', :as => :library_refresh
  match 'summary' => 'home#summary', :as => :summary
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => "home#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
