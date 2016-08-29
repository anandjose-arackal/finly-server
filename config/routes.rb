# == Route Map
#
#                           Prefix Verb   URI Pattern                                                 Controller#Action
#                       home_index GET    /home/index(.:format)                                       home#index
#                    accept_invite GET    /users/invitation/accept(.:format)                          pending_invites#edit
#                 new_user_session GET    /users/sign_in(.:format)                                    devise/sessions#new
#                     user_session POST   /users/sign_in(.:format)                                    devise/sessions#create
#             destroy_user_session DELETE /users/sign_out(.:format)                                   devise/sessions#destroy
#                    user_password POST   /users/password(.:format)                                   devise/passwords#create
#                new_user_password GET    /users/password/new(.:format)                               devise/passwords#new
#               edit_user_password GET    /users/password/edit(.:format)                              devise/passwords#edit
#                                  PATCH  /users/password(.:format)                                   devise/passwords#update
#                                  PUT    /users/password(.:format)                                   devise/passwords#update
#         cancel_user_registration GET    /users/cancel(.:format)                                     devise_invitable/registrations#cancel
#                user_registration POST   /users(.:format)                                            devise_invitable/registrations#create
#            new_user_registration GET    /users/sign_up(.:format)                                    devise_invitable/registrations#new
#           edit_user_registration GET    /users/edit(.:format)                                       devise_invitable/registrations#edit
#                                  PATCH  /users(.:format)                                            devise_invitable/registrations#update
#                                  PUT    /users(.:format)                                            devise_invitable/registrations#update
#                                  DELETE /users(.:format)                                            devise_invitable/registrations#destroy
#                user_confirmation POST   /users/confirmation(.:format)                               devise/confirmations#create
#            new_user_confirmation GET    /users/confirmation/new(.:format)                           devise/confirmations#new
#                                  GET    /users/confirmation(.:format)                               devise/confirmations#show
#                      user_unlock POST   /users/unlock(.:format)                                     devise/unlocks#create
#                  new_user_unlock GET    /users/unlock/new(.:format)                                 devise/unlocks#new
#                                  GET    /users/unlock(.:format)                                     devise/unlocks#show
#           accept_user_invitation GET    /users/invitation/accept(.:format)                          devise/invitations#edit
#           remove_user_invitation GET    /users/invitation/remove(.:format)                          devise/invitations#destroy
#                  user_invitation POST   /users/invitation(.:format)                                 devise/invitations#create
#              new_user_invitation GET    /users/invitation/new(.:format)                             devise/invitations#new
#                                  PATCH  /users/invitation(.:format)                                 devise/invitations#update
#                                  PUT    /users/invitation(.:format)                                 devise/invitations#update
#                         policies GET    /policies(.:format)                                         policies#index
#                                  POST   /policies(.:format)                                         policies#create
#                           policy GET    /policies/:id(.:format)                                     policies#show
#                                  PATCH  /policies/:id(.:format)                                     policies#update
#                                  PUT    /policies/:id(.:format)                                     policies#update
#                                  DELETE /policies/:id(.:format)                                     policies#destroy
#           policy_invitable_users POST   /policies/:policy_id/invitable_users(.:format)              policies#invitable_users
#                 policy_add_users POST   /policies/:policy_id/add_users(.:format)                    policies#add_users
#              policy_remove_users POST   /policies/:policy_id/remove_users(.:format)                 policies#remove_users
# policy_update_user_configuration PATCH  /policies/:policy_id/update_users_configuration(.:format)   policies#update_user_configuration
#                  policy_add_rule POST   /policies/:policy_id/add_rule(.:format)                     policies#add_rule
#               policy_remove_rule DELETE /policies/:policy_id/remove_rule(.:format)                  policies#remove_rule
#                                  GET    /policies(.:format)                                         policies#index
#                                  POST   /policies(.:format)                                         policies#create
#                       new_policy GET    /policies/new(.:format)                                     policies#new
#                      edit_policy GET    /policies/:id/edit(.:format)                                policies#edit
#                                  GET    /policies/:id(.:format)                                     policies#show
#                                  PATCH  /policies/:id(.:format)                                     policies#update
#                                  PUT    /policies/:id(.:format)                                     policies#update
#                                  DELETE /policies/:id(.:format)                                     policies#destroy
#                       categories GET    /categories(.:format)                                       categories#index
#                                  POST   /categories(.:format)                                       categories#create
#                     new_category GET    /categories/new(.:format)                                   categories#new
#                    edit_category GET    /categories/:id/edit(.:format)                              categories#edit
#                         category GET    /categories/:id(.:format)                                   categories#show
#                                  PATCH  /categories/:id(.:format)                                   categories#update
#                                  PUT    /categories/:id(.:format)                                   categories#update
#                                  DELETE /categories/:id(.:format)                                   categories#destroy
#               export_preferences GET    /export_preferences(.:format)                               export_preferences#index
#                                  POST   /export_preferences(.:format)                               export_preferences#create
#            new_export_preference GET    /export_preferences/new(.:format)                           export_preferences#new
#           edit_export_preference GET    /export_preferences/:id/edit(.:format)                      export_preferences#edit
#                export_preference GET    /export_preferences/:id(.:format)                           export_preferences#show
#                                  PATCH  /export_preferences/:id(.:format)                           export_preferences#update
#                                  PUT    /export_preferences/:id(.:format)                           export_preferences#update
#                                  DELETE /export_preferences/:id(.:format)                           export_preferences#destroy
#             organization_account GET    /organization_account(.:format)                             organization_account#show
#                     add_category POST   /add_category(.:format)                                     organization_account#add_category
#                  remove_category DELETE /remove_category(.:format)                                  organization_account#remove_category
#         update_export_preference PATCH  /export/:id/update(.:format)                                organization_account#update_export_column
#                 add_export_field POST   /add_export_field(.:format)                                 organization_account#add_export_column
#              delete_export_field DELETE /remove_export_field(.:format)                              organization_account#remove_export_column
#                           people GET    /people(.:format)                                           people#people
#                          reports GET    /reports(.:format)                                          reports#index
#                                  POST   /reports(.:format)                                          reports#create
#                           report GET    /reports/:id(.:format)                                      reports#show
#                                  PATCH  /reports/:id(.:format)                                      reports#update
#                                  PUT    /reports/:id(.:format)                                      reports#update
#                                  DELETE /reports/:id(.:format)                                      reports#destroy
#                    export_report GET    /export/report(.:format)                                    export#report
#                   report_comment POST   /reports/:report_id/comment(.:format)                       reports#comment
#                   report_retract PATCH  /reports/:report_id/retract(.:format)                       reports#retract
#                    report_submit PATCH  /reports/:report_id/submit(.:format)                        reports#submit
#                   report_approve PATCH  /reports/:report_id/approve(.:format)                       reports#approve
#                 report_unapprove PATCH  /reports/:report_id/unapprove(.:format)                     reports#unapprove
#                    report_reject PATCH  /reports/:report_id/reject(.:format)                        reports#reject
#                 report_reimburse PATCH  /reports/:report_id/reimburse(.:format)                     reports#reimburse
#     report_reimbursement_confirm PATCH  /reports/:report_id/reimbursement_confirm(.:format)         reports#reimbursement_confirm
#              report_take_control PATCH  /reports/:report_id/take_control(.:format)                  reports#take_control
#              report_add_expenses POST   /reports/:report_id/add_expenses(.:format)                  reports#add_expenses
#           report_remove_expenses DELETE /reports/:report_id/remove_expenses(.:format)               reports#remove_expenses
#             report_assign_policy POST   /reports/:report_id/assign_policy(.:format)                 reports#assign_policy
#                                  GET    /reports(.:format)                                          reports#index
#                                  POST   /reports(.:format)                                          reports#create
#                       new_report GET    /reports/new(.:format)                                      reports#new
#                      edit_report GET    /reports/:id/edit(.:format)                                 reports#edit
#                                  GET    /reports/:id(.:format)                                      reports#show
#                                  PATCH  /reports/:id(.:format)                                      reports#update
#                                  PUT    /reports/:id(.:format)                                      reports#update
#                                  DELETE /reports/:id(.:format)                                      reports#destroy
#           expense_attach_receipt POST   /expenses/:expense_id/attach_receipt(.:format)              expenses#attach_receipt
#           expense_detach_receipt POST   /expenses/:expense_id/detach_receipt(.:format)              expenses#detach_receipt
#              expense_add_receipt POST   /expenses/:expense_id/add_receipt(.:format)                 expenses#add_receipt
#                         expenses GET    /expenses(.:format)                                         expenses#index
#                                  POST   /expenses(.:format)                                         expenses#create
#                      new_expense GET    /expenses/new(.:format)                                     expenses#new
#                     edit_expense GET    /expenses/:id/edit(.:format)                                expenses#edit
#                          expense GET    /expenses/:id(.:format)                                     expenses#show
#                                  PATCH  /expenses/:id(.:format)                                     expenses#update
#                                  PUT    /expenses/:id(.:format)                                     expenses#update
#                                  DELETE /expenses/:id(.:format)                                     expenses#destroy
#              expenses_unreported POST   /expenses/unreported(.:format)                              expenses#unreported
#                 receipt_add_note POST   /receipts/:receipt_id/add_note(.:format)                    receipts#add_note
#                         receipts GET    /receipts(.:format)                                         receipts#index
#                                  POST   /receipts(.:format)                                         receipts#create
#                      new_receipt GET    /receipts/new(.:format)                                     receipts#new
#                     edit_receipt GET    /receipts/:id/edit(.:format)                                receipts#edit
#                          receipt GET    /receipts/:id(.:format)                                     receipts#show
#                                  PATCH  /receipts/:id(.:format)                                     receipts#update
#                                  PUT    /receipts/:id(.:format)                                     receipts#update
#                                  DELETE /receipts/:id(.:format)                                     receipts#destroy
#             expense_from_receipt POST   /expense_from_receipt(.:format)                             receipts#expense_from_receipt
#                     user_details POST   /users/:user_id/user_details(.:format)                      users#user_details
#                 user_update_team PATCH  /users/:user_id/update_user_team(.:format)                  users#update_team
#                 user_update_role PATCH  /users/:user_id/update_role(.:format)                       users#update_user_role
#                     user_profile GET    /users/:user_id/profile(.:format)                           users#profile
#             user_update_password POST   /users/:user_id/update_password(.:format)                   users#update_password
#                            users GET    /users(.:format)                                            users#index
#                                  POST   /users(.:format)                                            users#create
#                         new_user GET    /users/new(.:format)                                        users#new
#                        edit_user GET    /users/:id/edit(.:format)                                   users#edit
#                             user GET    /users/:id(.:format)                                        users#show
#                                  PATCH  /users/:id(.:format)                                        users#update
#                                  PUT    /users/:id(.:format)                                        users#update
#                                  DELETE /users/:id(.:format)                                        users#destroy
#        pending_invite_new_invite POST   /pending_invites/:pending_invite_id/invite(.:format)        pending_invites#invite
#       pending_invite_edit_invite PATCH  /pending_invites/:pending_invite_id/update_invite(.:format) pending_invites#update_invite
#                  pending_invites GET    /pending_invites(.:format)                                  pending_invites#index
#                                  POST   /pending_invites(.:format)                                  pending_invites#create
#               new_pending_invite GET    /pending_invites/new(.:format)                              pending_invites#new
#              edit_pending_invite GET    /pending_invites/:id/edit(.:format)                         pending_invites#edit
#                   pending_invite GET    /pending_invites/:id(.:format)                              pending_invites#show
#                                  PATCH  /pending_invites/:id(.:format)                              pending_invites#update
#                                  PUT    /pending_invites/:id(.:format)                              pending_invites#update
#                                  DELETE /pending_invites/:id(.:format)                              pending_invites#destroy
#                      settlements GET    /settlements(.:format)                                      settlements#index
#                                  POST   /settlements(.:format)                                      settlements#create
#                   new_settlement GET    /settlements/new(.:format)                                  settlements#new
#                  edit_settlement GET    /settlements/:id/edit(.:format)                             settlements#edit
#                       settlement GET    /settlements/:id(.:format)                                  settlements#show
#                                  PATCH  /settlements/:id(.:format)                                  settlements#update
#                                  PUT    /settlements/:id(.:format)                                  settlements#update
#                                  DELETE /settlements/:id(.:format)                                  settlements#destroy
#               settlement_partial POST   /settlements/:id/show_partial(.:format)                     settlements#show_partial
#           settlement_add_payment POST   /settlements/:id/add_payment(.:format)                      settlements#add_payment
#                        oauth_new GET    /oauth/new(.:format)                                        opro/oauth/auth#new
#                  oauth_authorize POST   /oauth/authorize(.:format)                                  opro/oauth/auth#create
#                      oauth_token POST   /oauth/token(.:format)                                      opro/oauth/token#create
#                oauth_client_apps GET    /oauth_client_apps(.:format)                                opro/oauth/client_app#index
#                                  POST   /oauth_client_apps(.:format)                                opro/oauth/client_app#create
#             new_oauth_client_app GET    /oauth_client_apps/new(.:format)                            opro/oauth/client_app#new
#            edit_oauth_client_app GET    /oauth_client_apps/:id/edit(.:format)                       opro/oauth/client_app#edit
#                 oauth_client_app GET    /oauth_client_apps/:id(.:format)                            opro/oauth/client_app#show
#                                  PATCH  /oauth_client_apps/:id(.:format)                            opro/oauth/client_app#update
#                                  PUT    /oauth_client_apps/:id(.:format)                            opro/oauth/client_app#update
#                                  DELETE /oauth_client_apps/:id(.:format)                            opro/oauth/client_app#destroy
#                       oauth_docs GET    /oauth_docs(.:format)                                       opro/oauth/docs#index
#                        oauth_doc GET    /oauth_docs/:id(.:format)                                   opro/oauth/docs#show
#                      oauth_tests GET    /oauth_tests(.:format)                                      opro/oauth/tests#index
#                                  POST   /oauth_tests(.:format)                                      opro/oauth/tests#create
#                       oauth_test GET    /oauth_tests/:id(.:format)                                  opro/oauth/tests#show
#                                  DELETE /oauth_tests/:id(.:format)                                  opro/oauth/tests#destroy
#                                  GET    /receipts(.:format)                                         receipts#index
#                                  POST   /receipts(.:format)                                         receipts#create
#                                  GET    /receipts/new(.:format)                                     receipts#new
#                                  GET    /receipts/:id/edit(.:format)                                receipts#edit
#                                  GET    /receipts/:id(.:format)                                     receipts#show
#                                  PATCH  /receipts/:id(.:format)                                     receipts#update
#                                  PUT    /receipts/:id(.:format)                                     receipts#update
#                                  DELETE /receipts/:id(.:format)                                     receipts#destroy
#                             root GET    /                                                           static_pages#home
#                            about GET    /about(.:format)                                            static_pages#about
#                         features GET    /features(.:format)                                         static_pages#features
#

Rails.application.routes.draw do

  # get 'home/index'

  mount_opro_oauth controllers: {
      oauth_new: 'oauth/auth',
      oauth_token: 'oauth/token'
  }
  # get 'policies' => 'policies#index'

  get '/users/invitation/accept', to: 'pending_invites#edit', as: :accept_invite

  devise_for :users

  namespace :api do
    namespace :v1 do
      resources :expenses, only: [:index, :show, :create, :update, :destroy]
      resources :reports, only: [:create, :index, :show, :update, :destroy]
      resources :reports do
        post 'comment' => 'reports#comment', as: :comment
        patch 'retract' => 'reports#retract', as: :retract
        patch 'submit' => 'reports#submit', as: :submit
        patch 'approve' => 'reports#approve', as: :approve
        patch 'unapprove' => 'reports#unapprove', as: :unapprove
        patch 'reject' => 'reports#reject', as: :reject
        patch 'reimbursement_confirm' => 'reports#reimbursement_confirm', as: :reimbursement_confirm
        patch 'take_control' => 'reports#take_control', as: :take_control
        post 'add_expenses' => 'reports#add_expenses', as: :add_expenses
        delete 'remove_expenses' => 'reports#remove_expenses', as: :remove_expenses
        post 'assign_policy', to: 'reports#assign_policy', as: :assign_policy
      end
      resources :receipts, only: [:create, :index, :destroy]
      resources :receipts do
        post 'add_note', to: 'receipts#add_note', as: :add_note
        post 'expense_from_receipt', to: 'receipts#expense_from_receipt', as: :expense_from_receipt
      end
    end
  end

  resources :policies, except: [:new, :edit]
  resources :policies do
    post 'invitable_users' => 'policies#invitable_users', as: :invitable_users
    post 'add_users' => 'policies#add_users', as: :add_users
    post 'remove_users' => 'policies#remove_users', as: :remove_users
    patch 'update_users_configuration' => 'policies#update_user_configuration', as: :update_user_configuration
    post 'add_rule', to: 'policies#add_rule', as: :add_rule
    delete 'remove_rule', to: 'policies#remove_rule', as: :remove_rule
  end

  resources :categories

  resources :export_preferences

  get 'organization_account' => 'organization_account#show'
  post 'add_category', to: 'organization_account#add_category', as: :add_category
  delete 'remove_category', to: 'organization_account#remove_category', as: :remove_category

  patch 'export/:id/update', to: 'organization_account#update_export_column', as: :update_export_preference
  post 'add_export_field', to: 'organization_account#add_export_column', as: :add_export_field
  delete 'remove_export_field', to: 'organization_account#remove_export_column', as: :delete_export_field

  get 'people' => 'people#people'

  resources :reports, except: [:new, :edit]
  get 'export/report(.:format)' => 'export#report', as: :export_report
  resources :reports do
    post 'comment' => 'reports#comment', as: :comment
    patch 'retract' => 'reports#retract', as: :retract
    patch 'submit' => 'reports#submit', as: :submit
    patch 'approve' => 'reports#approve', as: :approve
    patch 'unapprove' => 'reports#unapprove', as: :unapprove
    patch 'reject' => 'reports#reject', as: :reject
    patch 'reimbursement_confirm' => 'reports#reimbursement_confirm', as: :reimbursement_confirm
    patch 'take_control' => 'reports#take_control', as: :take_control
    post 'add_expenses' => 'reports#add_expenses', as: :add_expenses
    delete 'remove_expenses' => 'reports#remove_expenses', as: :remove_expenses
    post 'assign_policy', to: 'reports#assign_policy', as: :assign_policy
  end

  resources :expenses do
    post 'attach_receipt', to: 'expenses#attach_receipt'
    post 'detach_receipt', to: 'expenses#detach_receipt'
    post 'add_receipt', to: 'expenses#add_receipt'
  end
  post 'expenses/unreported', to: 'expenses#unreported', as: :expenses_unreported

  resources :receipts do
    post 'add_note', to: 'receipts#add_note', as: :add_note
  end

  post 'expense_from_receipt', to: 'receipts#expense_from_receipt', as: :expense_from_receipt

  resources :users do
    post 'user_details', to: 'users#user_details', as: :details
    patch 'update_user_team', to: 'users#update_team', as: :update_team
    patch 'update_role', to: 'users#update_user_role', as: :update_role
    get 'profile', to: 'users#profile', as: :profile
    post 'update_password', to: 'users#update_password', as: :update_password
  end

  resources :pending_invites do
    post 'invite', to: 'pending_invites#invite', as: :new_invite
    patch 'update_invite', to: 'pending_invites#update_invite', as: :edit_invite
  end


  resources :settlements
  post 'settlements/:id/show_partial' => 'settlements#show_partial', as: :settlement_partial
  post 'settlements/:id/add_payment' => 'settlements#add_payment', as: :settlement_add_payment

  resources :receipts do

  end

  root 'home#index'
  get 'welcome' => 'home#welcome'

  get 'about', to: 'home#about'


  #Filters/Autocomplete
  get 'autocomplete/merchant'
  get 'autocomplete/user'

  # get 'features', to: 'static_pages#features'

  get 'external/reports/:id' => 'external_url#report', as: :external_url_report

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
