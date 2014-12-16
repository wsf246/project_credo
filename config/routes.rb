ProjectCredo::Application.routes.draw do
  root 'static_pages#home'
  get '/help' => 'static_pages#help'
  get '/about' => 'static_pages#about'
  get '/contact' => 'static_pages#contact'
  get '/howto' => 'static_pages#howto'
  
  post "versions/:id/revert" => "versions#revert", :as => "revert_version"

  resources :questions do
    collection do
      match 'search' => 'questions#search', via: [:get, :post], as: :search
      match 'add_verdict' => 'questions#add_verdict', via: [:get, :post]
      match 'select_verdict' => 'questions#select_verdict', via: [:get, :post] 
      match 'edit_verdict' => 'questions#edit_verdict', via: [:get, :post]
    end

    member do
      get 'edit_history', to: 'questions#edit_history'                
      put "upvote", to: "questions#upvote"
      put "downvote", to: "questions#downvote"
      put "unvote", to: "questions#unvote" 
      match 'select_findings' => 'questions#select_findings', via: [:get, :post]
      match 'remove_finding' => 'questions#remove_finding', via: [:get, :post]
      match 'all_research' => 'questions#all_research', via: [:get, :post]  
      match 'less_research' => 'questions#less_research', via: [:get, :post]          
    end    

    resources :verdicts, shallow: true do
      member do
        put "upvote", to: "verdicts#upvote"
        put "downvote", to: "verdicts#downvote"
        put "unvote", to: "verdicts#unvote"
      end      
    end
    
    resources :points, shallow: true do
      collection do
        match 'search' => 'points#search', via: [:get, :post], as: :search
      end
      member do
        put "upvote", to: "points#upvote"
        put "downvote", to: "points#downvote"
        put "unvote", to: "points#unvote"
      end
    end  
  end  

  resources :researches do
    collection do
      match 'search' => 'researches#search', via: [:get, :post], as: :search
      match 'pubmed_search' => 'researches#pubmed_search', via: [:get, :post]    
      match 'view_result' => 'researches#view_result', via: [:get, :post]        
      match 'fill_in_form' => 'researches#fill_in_form', via: [:get, :post]
      match 'edit_in_form' => 'researches#edit_in_form', via: [:get, :post]     
      get :autocomplete_journal_name
    end 
    member do
      get 'edit_history', to: 'researches#edit_history'                
    end        
  end  

  resources :findings do
    collection do
      match 'search' => 'findings#search', via: [:get, :post], as: :search
    end
  end   

  resources :associations, only: [:create, :destroy]      

devise_for :users, controllers: { registrations: 'users/registrations', passwords: 'users/passwords' }
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
