

Rails.application.routes.draw do

  mount Crono::Web, at: '/crono'

  namespace :transcriber do
    post 'expenses/create', to: 'receipts#create_expense', as: :transcribed_expenses_create
    patch 'expenses/:id/update', to: 'receipts#update_expense', as: :transcribed_expenses_update
    get 'expenses/:id/show', to: 'receipts#show', as: :transcribed_receipt_show
    get 'companies/:id', to: 'companies#show', as: :untranscribed_receipts
    get 'companies', to: 'companies#index', as: :companies
  end

  get 'menu_data', to: 'users#menu_data'

  devise_for :admin_users, controllers: {sessions: 'admin_users/sessions'}

  namespace :api do
    namespace :v1 do
      namespace :configuration do
        get 'category/index'
      end
    end
  end

  namespace :api do
    namespace :v1 do
      get 'configuration/category'
    end
  end

  # get 'home/index'


  mount_griddler('/email/incoming')
  mount_opro_oauth controllers: {
      oauth_new: 'oauth/auth',
      oauth_token: 'oauth/token'
  }
  # adding admin oauth token creation for admin login
  post 'admin/oauth/token', to: 'admin_users/oauth/token#create', as: :admin_oauth_token_generate, defaults: {format: 'json'}

  get '/users/invitation/accept', to: 'pending_invites#edit', as: :accept_invite

  post '/welcome/preview', to: 'registrations#preview', as: :preview_registration
  post '/resources_details', to: 'registrations#resource_requests', as: :resources_details
  get 'download_resource', to: 'registrations#resources_download', as: :resources_download

  devise_for :users, controllers: {passwords: "passwords", sessions: "sessions"} do
    # get 'login', to: 'sessions#new', as: :login
    # post 'login', to: 'session#create', as: :login

  end

  namespace :api do
    namespace :v0 do
      resources :expenses, only: [:index, :show, :create, :update, :destroy]
      resources :reports, only: [:create, :index, :show, :update, :destroy]
      resources :reports do
        post 'comment' => 'reports#comment', as: :comment
        patch 'retract' => 'reports#retract', as: :retract
        patch 'submit' => 'reports#submit', as: :submit
        patch 'approve' => 'reports#approve', as: :approve
        patch 'unapprove' => 'reports#unapprove', as: :unapprove
        patch 'reject' => 'reports#reject', as: :reject
        patch 'settlement_confirm' => 'reports#settlement_confirm', as: :settlement_confirm
        patch 'take_control' => 'reports#take_control', as: :take_control
        post 'add_expenses' => 'reports#add_expenses', as: :add_expenses
        delete 'remove_expenses' => 'reports#remove_expenses', as: :remove_expenses
        patch 'reject_expense' => 'reports#reject_expense', as: :reject_expense
        post 'assign_policy', to: 'reports#assign_policy', as: :assign_policy
      end
      resources :receipts, only: [:create, :index, :destroy, :update]
      resources :receipts do
        post 'expense_from_receipt', to: 'receipts#expense_from_receipt', as: :expense_from_receipt
      end
      namespace :configuration do
        get 'categories' => 'category#index', as: :categories
        post 'gcm/register', to: 'gcm#create'
        post 'gcm/unregister', to: 'gcm#delete'
      end
    end
    namespace :v1 do
      resources :expenses, only: [:index, :show, :create, :update, :destroy]
      resources :reports, only: [:create, :index, :show, :update, :destroy]
      resources :reports do
        post 'comment' => 'reports#comment', as: :comment
      end
      resources :money_requests, only: [:create, :index, :show, :destroy, :update]
      resources :money_requests do
        post 'comment' => 'money_requests#comment', as: :comment
      end
      resources :receipts, only: [:create, :index, :destroy, :update]
      resources :receipts do
        post 'add_note', to: 'receipts#add_note', as: :add_note
        post 'expense_from_receipt', to: 'receipts#expense_from_receipt', as: :expense_from_receipt
      end
      resources :users, only: [:index, :show]
      resources :users do
        get 'summary', to: 'users#summary', as: :user_summary
      end
      post 'cards/balance/update', to: 'cards#update_balance'
      post 'cards/status/update', to: 'cards#update_status'
      namespace :configuration do
        get 'categories' => 'category#index', as: :categories
        post 'gcm/register', to: 'gcm#create'
        post 'gcm/unregister', to: 'gcm#delete'
      end
      get 'balances', to: 'users#balance'
      get 'available_expense_types', to: 'expenses#available_expense_types'
    end
  end

  get 'policies/expense_rules' => 'policies#expense_rules'
  get 'policies/budget_rules' => 'policies#budget_rules'
  get 'policies/policy_members' => 'policies#policy_members'
  get 'policies/create_rule' => 'policies#create_rule'
  get 'policies/policy_member_settings/' => 'policies#policy_member_settings'

  get 'policies/details' => 'policies#details'
  get 'policies/personal' => 'policies#show_personal'
  resources :policies, except: [:new, :edit]
  resources :policies do
    post 'invitable_users' => 'policies#invitable_users', as: :invitable_users
    post 'add_users' => 'policies#add_users', as: :add_users
    post 'remove_users' => 'policies#remove_users', as: :remove_users
    patch 'update_users_configuration' => 'policies#update_user_configuration', as: :update_user_configuration
    delete 'remove_mapping/:mapping_id' => 'policies#destrot_mapping', as: :destroy_mapping
    post 'add_rule', to: 'rules#create', as: :add_rule
    delete 'remove_rule', to: 'rules#destroy', as: :remove_rule
    get 'description', to: 'policies#show_description'
  end

  resources :categories

  resources :export_preferences

  resources :card_restrictions

  get 'companies/notify', to: 'companies#notify'
  resources :companies do
    post 'add_balance', to: 'companies#add_balance', as: :add_balance
  end

  # get 'organization_account' => 'organization_account#show'
  get 'organization_account/policies_list' => 'organization_account#policies_list' #todo
  get 'organization_account/categories' => 'organization_account#categories'
  get 'organization_account/export_preferences' => 'organization_account#export_preferences'

  post 'add_category', to: 'organization_account#add_category', as: :add_category
  delete 'remove_category', to: 'organization_account#remove_category', as: :remove_category

  patch 'export/:id/update', to: 'organization_account#update_export_column', as: :update_export_preference
  post 'add_export_field', to: 'organization_account#add_export_column', as: :add_export_field
  delete 'remove_export_field', to: 'organization_account#remove_export_column', as: :delete_export_field

  get 'people' => 'people#people'

  get 'users/verify' => 'otp#edit', as: :verify_mobile
  post 'otp/update' => 'otp#update', as: :update_mobile_number
  post 'otp/verify' => 'otp#verify', as: :verify_otp
  post 'otp/resend' => 'otp#resend', as: :resend_otp


  post 'cards/details' => 'cards#details', as: :card_details
  post 'cards/update_balance' => 'cards#update_balance', as: :update_balance
  post 'cards/update_status' => 'cards#update_status', as: :update_card_status

  resources :reports, except: [:new, :edit]
  get 'export/report(.:format)' => 'export#report', as: :export_report
  resources :reports do
    post 'comment' => 'reports#comment', as: :comment
    patch 'retract' => 'reports#retract', as: :retract
    patch 'submit' => 'reports#submit', as: :submit
    patch 'approve' => 'reports#approve', as: :approve
    patch 'unapprove' => 'reports#unapprove', as: :unapprove
    patch 'reject' => 'reports#reject', as: :reject
    patch 'reject_expense' => 'reports#reject_expense', as: :reject_expense
    patch 'settlement_confirm' => 'reports#settlement_confirm', as: :settlement_confirm
    patch 'take_control' => 'reports#take_control', as: :take_control
    post 'add_expenses' => 'reports#add_expenses', as: :add_expenses
    delete 'remove_expenses' => 'reports#remove_expenses', as: :remove_expenses
  end

  resources :money_request, only: [:create, :index, :show, :destroy, :update]
  resources :money_request do
    post 'comment' => 'money_request#comment', as: :comment
  end

  resources :expenses do
    post 'attach_receipt', to: 'expenses#attach_receipt'
    post 'detach_receipt', to: 'expenses#detach_receipt'
    post 'add_receipt', to: 'expenses#add_receipt'
    patch 'mark', to: 'expenses#mark', as: :mark
    patch 'unmark', to: 'expenses#unmark', as: :unmark
  end


  post 'expenses/unreported', to: 'expenses#unreported', as: :expenses_unreported

  resources :receipts do
    post 'add_note', to: 'receipts#add_note', as: :add_note
    patch 'enable', to: 'receipts#enable_transcription', as: :enable_transcription
    patch 'disable', to: 'receipts#disable_transcription', as: :disable_transcription
  end

  post 'expense_from_receipt', to: 'receipts#expense_from_receipt', as: :expense_from_receipt

  get 'users/get_managers', to: 'users#get_managers'

  #Backbone partials
  get 'users/user_profile'
  get 'users/user_balance'
  get 'users/user_security'
  #backbone partials for users ends

  # routes for lookup and first tome otp
  get 'lookup', to: 'users#lookup', as: :lookup
  post 'send_verification_otp', to: 'users#send_verification_otp', as: :send_verification_otp
  post 'verify_user_otp', to: 'users#verify_user_otp', as: :verify_user_otp
  post 'set_password', to: 'users#set_new_password', as: :set_password

  resources :users, only: [:create, :update, :index, :destroy, :show]
  resources :users do
    get 'summary', to: 'users#summary', as: :user_summary
    post 'user_details', to: 'users#user_details', as: :details
    patch 'update_user_team', to: 'users#update_team', as: :update_team
    patch 'update_role', to: 'users#update_user_role', as: :update_role
    get 'profile', to: 'users#profile', as: :profile
    post 'update_password', to: 'users#update_password', as: :update_password
    get 'balance', to: 'users#balance', as: :balance
    get 'verify_reset_otp', to: 'users#verify_reset_password_otp', as: :verify_reset_password_otp
  end
  get 'available_expense_types', to: 'users#available_expense_types', as: :available_expense_types

  # routes for testing import
  # get 'mass_import', to: 'users#mass_import', as: :mass_import
  post 'import', to: 'users#import', as: :user_import
  post 'superadmin_import', to: 'admin/companies#import', as: :superadmin_import
  # get 'sample_import_file', to: 'users#sample_file', as: :sample_import_file

  get 'pending_invites/initiate_activation', to: 'pending_invites#initiate_activation', as: :initiate_activation
  get 'pending_invites/activate_employee' => 'pending_invites#activate_employee', as: :activate_employee
  get 'pending_invites/send_otp', to: 'pending_invites#send_otp', as: :send_otp
  patch 'pending_invites/manager_sign_up', to: 'pending_invites#manager_sign_up', as: :manager_activation_sign_up
  post 'users/update_default_password', to: 'users#update_default_password', as: :update_default_password
  get 'edit_default_password', to: 'users#edit_default_password', as: :edit_default_password


  resources :pending_invites, only: [:create, :destroy, :update, :edit]
  resources :pending_invites do
    patch 'accept', to: 'pending_invites#accept', as: :accept
  end


  get 'settlements/summary' => 'settlements#summary'
  resources :settlements
  post 'settlements/:id/add_payment' => 'settlements#add_payment', as: :settlement_add_payment

  resources :receipts do

  end

  get 'expense_type_configurations', to: 'expense_types_configuration#show', as: :expense_type_configuration_show
  patch 'expense_type_configurations', to: 'expense_types_configuration#update', as: :expense_type_configuration_update
  
  resources :per_diems

  namespace :admin_users do
    resources :companies
    resources :users do
      patch 'update_status', to: 'users#update_status', as: :update_status
      patch 'update_mapping', to: 'users#update_mapping', as: :update_mapping
      delete 'destroy_mapping', to: 'users#destroy_mapping', as: :destroy_mapping
    end
    post 'welcome', to: 'users#admin_welcome', as: :welcome
    post 'users/set_role', to: 'users#set_role', as: :set_role
    get 'lookup', to: 'users#lookup',as: :lookup
    post 'import', to: 'users#import', as: :import
    get 'temp_import', to: 'users#temp_import'
    resources :expenses
    resources :cards do
      patch 'block', to: 'cards#block', as: :block
    end
  end

  get 'admin_menus', to: 'admin_users/users#admin_menus', as: :admin_menu

  namespace :transcriber do
    resources :expenses
    resources :companies
    resources :receipts
  end

  resources :card_transactions do

  end
  get 'cancelled_against_transactions/:expense_id', to: 'card_transactions#cancelled_transactions', as: :cancelled_transactions
  
  get 'statements/company_balance_summary' => 'statements#company_balance_summary'
  get 'statements/company_transactions_summary' => 'statements#company_transactions_summary'
  get 'statements/company_policies_summary' => 'statements#company_policies_summary'

  get 'statements/:id/summary' => 'statements#summary'
  get 'export/:id/statements(.:format)', to: 'export#statement', as: :export_statement
  resources :statements

  # get 'settlements/summary' => 'settlements#summary'

  root 'home#index'
  get 'welcome' => 'home#welcome'

  get 'about', to: 'home#about'
  get 'resources', to: 'home#resources'


  #Filters/Autocomplete
  get 'autocomplete/merchant'
  get 'autocomplete/user'


  # get 'features', to: 'static_pages#features'

  get 'external/reports/:id' => 'external_url#report', as: :external_url_report
  get 'external/requests/:id' => 'external_url#money_request', as: :external_url_money_request
  get 'external/settlements/:id' => 'external_url#payment', as: :external_url_settlement
  get 'external/transaction/:id' => 'external_url#transaction', as: :external_url_transaction

  get 'analytics' => 'analytics#show'

  get 'companies/notify' => 'companies#notify'

  get 'notifications' => 'notifications#index'

  get 'notifications/unread' => 'notifications#unread'
  get 'notifications/mark_all_read' => 'notifications#mark_all_read'

  # FAQ
  get '/faqs' => 'faqs#index'

  post 'feedback' => 'feedback#create'

  # Cards Module APIS
  # Getting Menu Data for Cards module
  get 'menu_data_cards' => 'expense_types_configuration#menu_data_cards'
  get 'menu_data_disburse' => 'expense_types_configuration#menu_data_disburse'

  # Orders
  get 'cards/orders' => 'orders/order_cards#index'
  get 'cards/orders/:id' => 'orders/order_cards#show'
  delete 'cards/orders/:id' => 'orders/order_cards#destroy'

  # Meal Cards
  post 'cards/meal/process_file' => 'benefits/meal_cards#process_file'
  post 'cards/meal/orders' => 'benefits/meal_cards#create'
  patch 'cards/meal/orders' => 'benefits/meal_cards#update'
  get 'cards/meal/orders' => 'benefits/meal_cards#index'
  get 'cards/meal/orders/:id' => 'benefits/meal_cards#show'
  delete 'cards/meal/orders/:id' => 'benefits/meal_cards#destroy'

  # Medical Cards


  
  post 'cards/medical/process_file' => 'benefits/medical_cards#process_file'
  post 'cards/medical/orders' => 'benefits/medical_cards#create'
  patch 'cards/medical/orders' => 'benefits/medical_cards#update'
  get 'cards/medical/orders' => 'benefits/medical_cards#index'
  get 'cards/medical/orders/:id' => 'benefits/medical_cards#show'
  delete 'cards/medical/orders/:id' => 'benefits/medical_cards#destroy'

  # Mass Credit for Expense Cards
  post 'cards/expense/process_file' => 'benefits/expense_cards#process_file'
  post 'cards/expense/orders' => 'benefits/expense_cards#create'
  patch 'cards/expense/orders' => 'benefits/expense_cards#update'
  get 'cards/expense/orders' => 'benefits/expense_cards#index'
  get 'cards/expense/orders/:id' => 'benefits/expense_cards#show'
  delete 'cards/expense/orders/:id' => 'benefits/expense_cards#destroy'

  # Mass Credit for Expense Cards
  post 'cards/reimbursement/process_file' => 'benefits/reimbursement_cards#process_file'
  post 'cards/reimbursement/orders' => 'benefits/reimbursement_cards#create'
  patch 'cards/reimbursement/orders' => 'benefits/reimbursement_cards#update'
  get 'cards/reimbursement/orders' => 'benefits/reimbursement_cards#index'
  get 'cards/reimbursement/orders/:id' => 'benefits/reimbursement_cards#show'
  delete 'cards/reimbursement/orders/:id' => 'benefits/reimbursement_cards#destroy'

  namespace :bank_transfer do
    get 'reimbursements' => 'reimbursement#show'
    patch 'reimbursements' => 'reimbursement#update'
    post 'reimbursements' => 'reimbursement#create'
  end


  # Disburse
  post 'disburse/users' => 'disburse/users#create'

  get 'features_subscribed' => 'expense_types_configuration#features_subscribed'

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
