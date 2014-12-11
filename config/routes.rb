Home::Application.routes.draw do
  resources :grocery_list_items


  match 'receipt_item_types/autocomplete' => 'receipt_item_types#autocomplete_receipt_item_type_friendly_name', :as => :autocomplete_receipt_item_type, :via => :get
  resources :receipt_item_types do
    collection do
      get :batch_entry
      post :batch_entry
    end
  end

  resources :receipt_item_categories

  resources :receipt_items do
    collection do
      get :batch_entry
      post :batch_entry
      get :graph
    end
  end

  resources :grocery_lists do
    member do
      post :quick_add_to
      post :clear
      delete :unshare
      get :items_for
    end
  end
  resources :goals
  devise_scope :user do
    match 'auth/:service/callback' => 'services#create', :via => [:get, :post]
    match 'auth/:service' => 'sessions#setup', :as => :oauth, :via => [:get, :post]
  end 

  resources :services, :only => [:index, :create, :destroy]
  get 'privacy' => 'home#privacy'
  match 'admin' => 'admin#index', :as => 'admin', :via => :get
  match 'admin/become/:id' => 'admin#become', :as => :become_user, :via => :post
  match 'feedback' => 'home#send_feedback', :as => :send_feedback, :via => :post
  match 'feedback' => 'home#feedback', :as => :feedback, :via => :get
  match 'help/record_categories' => 'help#record_categories', :via => :get
  offline = Rack::Offline.configure do
    cache "api/offline/v1/track"
    cache "assets/application.js"
    cache "assets/offline.js"
    cache "assets/application.css"
    cache "assets/mobile.css"
    cache "assets/offline.css"
    network "/"
  end
  #match '/offline.manifest' => offline

  match 'records/batch' => 'records#batch', :as => :batch_records, :via => [:post, :get]
  resources :timeline_events, :except => [:create, :update]
  resources :records do
    collection do
      get :help
    end
    member do
      post :clone
    end
  end
  match 'toronto_libraries/refresh_all' => 'toronto_libraries#refresh_all', :as => :library_refresh, :via => [:get, :post]
  match 'toronto_libraries/:id/request' => 'toronto_libraries#request_items', :as => :request_library_items, :via => :post

  match 'record_categories/autocomplete' => 'record_categories#autocomplete_record_category_full_name', :as => :autocomplete_record_category, :via => :get
  match 'stuff/autocomplete' => 'stuff#autocomplete_stuff_name', :as => :autocomplete_stuff, :via => :get
  resources :record_categories do
    member do
      post :track
      get :records
    end
    collection do
      post :bulk_update
      get :tree
      get :disambiguate
    end
  end

  resources :memories

  resources :contexts do
    member do
      get :start
      put :complete
    end
  end

  resources :tap_log_records do
    member do
      post :copy_to_memory
    end
  end
  resources :measurement_logs

  resources :measurements
  resources :locations do
    member do
      get :stuff
    end
  end
  resources :stuff do
    member do
      get :history
    end
    collection do
      get :bulk
      post :bulk_update
    end
  end
  
  resources :location_histories, only: [:index, :show, :destroy]
  match 'stuff/log', :via => :post, :as => :log_stuff
  match 'menu' => 'home#menu', :via => :get, :as => :menu

  match 'csa_foods/bulk_update', :as => :bulk_update_csa_foods, :via => :post
  resources :csa_foods do
    collection do
      post :quick_entry 
    end
  end

  resources :foods

  devise_for :users, :path_prefix => 'd', :controllers => { :sessions => 'sessions', :registrations => 'registrations' }
  resources :users do
    member do
      post :generate_token
    end
  end

  resources :decision_logs

  resources :decisions
  resources :toronto_libraries 

  resources :library_items do
    get :tag, :on => :collection
    get :current, :on => :collection
  end

  match 'library_items/bulk', :as => :library_item_bulk, :via => :post

  match 'time/graph(/:url_start(/:url_end))' => 'time#graph', :as => :time_graph, :via => :get
  match 'time/dashboard' => 'time#dashboard', :as => :time_dashboard, :via => :get
  match 'time/refresh' => 'time#refresh_from_csv', :as => :refresh_from_csv, :via => :post
  match 'time/refresh' => 'time#refresh', :as => :refresh_time, :via => :get
  match 'time/review' => 'time#review', :as => :time_review, :via => :get
  match 'time/track' => 'time#track', :as => :track_time, :via => [:post, :get]
  match 'time/batch' => 'records#batch', :as => :time_batch_records, :via => [:post, :get]

  match 'time/track' => 'time#dashboard', :via => :get
  match 'time' => 'time#dashboard', :via => :get
  match 'clothing/bulk' => 'clothing#bulk', :as => :clothing_bulk, :via => :post
  match 'clothing/missing_info' => 'clothing#update_missing_info', :as => :update_missing_clothing_information, :via => :post
  match 'clothing/missing_info' => 'clothing#missing_info', :as => :missing_clothing_information, :via => :get
  match 'clothing/:id/save_color' => 'clothing#save_color', :as => :save_clothing_color, :via => :post
  match 'clothing/:id/:color' => 'clothing#delete_color', :as => :delete_clothing_color, :via => :delete
  match 'clothing_logs/by_date/:date' => 'clothing_logs#by_date', :as => :clothing_logs_by_date, :via => :get
  match 'clothing/tag/:id' => 'clothing#tag', :as => :clothing_by_tag, :via => :get
  match 'clothing/status/:status' => 'clothing#by_status', :as => :clothing_by_status, :via => :get
  match 'clothing/analyze(/:start(/:end))' => 'clothing#analyze', :as => :analyze_clothing, :via => :get
  match 'clothing/graph(/:start(/:end))' => 'clothing#graph', :as => :graph_clothing, :via => :get
  resources :clothing do
    collection do
      get :autocomplete_clothing_name
    end
    member do
      get :clothing_logs
    end
  end

  resources :clothing_logs do
    collection do
      get :matches
    end
  end
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

  namespace :api do
    namespace :v1 do
      match 'create' => 'tokens#create', via: :post
      match 'destroy' => 'tokens#destroy', via: :delete
      match 'tokens' => 'tokens#create', via: :post
      resources :records
    end
    namespace :offline do
      namespace :v1 do
        match 'track' => 'offline#track', :as => :track_offline, :via => :get
        match 'bulk_track' => 'offline#bulk_track', :via => :post
        match 'bulk_track' => 'offline#bulk_track', :via => :get
      end
    end
  end
  
  
end

