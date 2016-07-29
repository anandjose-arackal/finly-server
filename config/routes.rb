# == Route Map
#
#                           Prefix Verb   URI Pattern                                               Controller#Action
#                 new_user_session GET    /users/sign_in(.:format)                                  devise/sessions#new
#                     user_session POST   /users/sign_in(.:format)                                  devise/sessions#create
#             destroy_user_session DELETE /users/sign_out(.:format)                                 devise/sessions#destroy
#                    user_password POST   /users/password(.:format)                                 devise/passwords#create
#                new_user_password GET    /users/password/new(.:format)                             devise/passwords#new
#               edit_user_password GET    /users/password/edit(.:format)                            devise/passwords#edit
#                                  PATCH  /users/password(.:format)                                 devise/passwords#update
#                                  PUT    /users/password(.:format)                                 devise/passwords#update
#         cancel_user_registration GET    /users/cancel(.:format)                                   devise_invitable/registrations#cancel
#                user_registration POST   /users(.:format)                                          devise_invitable/registrations#create
#            new_user_registration GET    /users/sign_up(.:format)                                  devise_invitable/registrations#new
#           edit_user_registration GET    /users/edit(.:format)                                     devise_invitable/registrations#edit
#                                  PATCH  /users(.:format)                                          devise_invitable/registrations#update
#                                  PUT    /users(.:format)                                          devise_invitable/registrations#update
#                                  DELETE /users(.:format)                                          devise_invitable/registrations#destroy
#                user_confirmation POST   /users/confirmation(.:format)                             devise/confirmations#create
#            new_user_confirmation GET    /users/confirmation/new(.:format)                         devise/confirmations#new
#                                  GET    /users/confirmation(.:format)                             devise/confirmations#show
#                      user_unlock POST   /users/unlock(.:format)                                   devise/unlocks#create
#                  new_user_unlock GET    /users/unlock/new(.:format)                               devise/unlocks#new
#                                  GET    /users/unlock(.:format)                                   devise/unlocks#show
#           accept_user_invitation GET    /users/invitation/accept(.:format)                        devise/invitations#edit
#           remove_user_invitation GET    /users/invitation/remove(.:format)                        devise/invitations#destroy
#                  user_invitation POST   /users/invitation(.:format)                               devise/invitations#create
#              new_user_invitation GET    /users/invitation/new(.:format)                           devise/invitations#new
#                                  PATCH  /users/invitation(.:format)                               devise/invitations#update
#                                  PUT    /users/invitation(.:format)                               devise/invitations#update
#                         policies GET    /policies(.:format)                                       policies#index
#                                  POST   /policies(.:format)                                       policies#create
#                           policy GET    /policies/:id(.:format)                                   policies#show
#                                  PATCH  /policies/:id(.:format)                                   policies#update
#                                  PUT    /policies/:id(.:format)                                   policies#update
#                                  DELETE /policies/:id(.:format)                                   policies#destroy
#           policy_invitable_users POST   /policies/:policy_id/invitable_users(.:format)            policies#invitable_users
#                 policy_add_users POST   /policies/:policy_id/add_users(.:format)                  policies#add_users
#              policy_remove_users POST   /policies/:policy_id/remove_users(.:format)               policies#remove_users
# policy_update_user_configuration PATCH  /policies/:policy_id/update_users_configuration(.:format) policies#update_user_configuration
#                  policy_add_rule POST   /policies/:policy_id/add_rule(.:format)                   policies#add_rule
#                                  GET    /policies(.:format)                                       policies#index
#                                  POST   /policies(.:format)                                       policies#create
#                       new_policy GET    /policies/new(.:format)                                   policies#new
#                      edit_policy GET    /policies/:id/edit(.:format)                              policies#edit
#                                  GET    /policies/:id(.:format)                                   policies#show
#                                  PATCH  /policies/:id(.:format)                                   policies#update
#                                  PUT    /policies/:id(.:format)                                   policies#update
#                                  DELETE /policies/:id(.:format)                                   policies#destroy
#             organization_account GET    /organization_account(.:format)                           organization_account#organization_account
#                           people GET    /people(.:format)                                         people#people
#                          reports GET    /reports(.:format)                                        reports#index
#                                  POST   /reports(.:format)                                        reports#create
#                           report GET    /reports/:id(.:format)                                    reports#show
#                                  PATCH  /reports/:id(.:format)                                    reports#update
#                                  PUT    /reports/:id(.:format)                                    reports#update
#                                  DELETE /reports/:id(.:format)                                    reports#destroy
#                    export_report GET    /export/report(.:format)                                  export#report
#                   report_comment POST   /reports/:report_id/comment(.:format)                     reports#comment
#                   report_retract PATCH  /reports/:report_id/retract(.:format)                     reports#retract
#                    report_submit PATCH  /reports/:report_id/submit(.:format)                      reports#submit
#                   report_approve PATCH  /reports/:report_id/approve(.:format)                     reports#approve
#                 report_unapprove PATCH  /reports/:report_id/unapprove(.:format)                   reports#unapprove
#                    report_reject PATCH  /reports/:report_id/reject(.:format)                      reports#reject
#                 report_reimburse PATCH  /reports/:report_id/reimburse(.:format)                   reports#reimburse
#     report_reimbursement_confirm PATCH  /reports/:report_id/reimbursement_confirm(.:format)       reports#reimbursement_confirm
#              report_take_control PATCH  /reports/:report_id/take_control(.:format)                reports#take_control
#              report_add_expenses POST   /reports/:report_id/add_expenses(.:format)                reports#add_expenses
#           report_remove_expenses DELETE /reports/:report_id/remove_expenses(.:format)             reports#remove_expenses
#             report_assign_policy POST   /reports/:report_id/assign_policy(.:format)               reports#assign_policy
#                                  GET    /reports(.:format)                                        reports#index
#                                  POST   /reports(.:format)                                        reports#create
#                       new_report GET    /reports/new(.:format)                                    reports#new
#                      edit_report GET    /reports/:id/edit(.:format)                               reports#edit
#                                  GET    /reports/:id(.:format)                                    reports#show
#                                  PATCH  /reports/:id(.:format)                                    reports#update
#                                  PUT    /reports/:id(.:format)                                    reports#update
#                                  DELETE /reports/:id(.:format)                                    reports#destroy
#           expense_attach_receipt POST   /expenses/:expense_id/attach_receipt(.:format)            expenses#attach_receipt
#           expense_detach_receipt POST   /expenses/:expense_id/detach_receipt(.:format)            expenses#detach_receipt
#              expense_add_receipt POST   /expenses/:expense_id/add_receipt(.:format)               expenses#add_receipt
#                         expenses GET    /expenses(.:format)                                       expenses#index
#                                  POST   /expenses(.:format)                                       expenses#create
#                      new_expense GET    /expenses/new(.:format)                                   expenses#new
#                     edit_expense GET    /expenses/:id/edit(.:format)                              expenses#edit
#                          expense GET    /expenses/:id(.:format)                                   expenses#show
#                                  PATCH  /expenses/:id(.:format)                                   expenses#update
#                                  PUT    /expenses/:id(.:format)                                   expenses#update
#                                  DELETE /expenses/:id(.:format)                                   expenses#destroy
#                     user_details POST   /users/:user_id/user_details(.:format)                    users#user_details
#                 user_update_team POST   /users/:user_id/update_user_team(.:format)                users#update_team
#                 user_update_role POST   /users/:user_id/update_role(.:format)                     users#update_role
#                            users GET    /users(.:format)                                          users#index
#                                  POST   /users(.:format)                                          users#create
#                         new_user GET    /users/new(.:format)                                      users#new
#                        edit_user GET    /users/:id/edit(.:format)                                 users#edit
#                             user GET    /users/:id(.:format)                                      users#show
#                                  PATCH  /users/:id(.:format)                                      users#update
#                                  PUT    /users/:id(.:format)                                      users#update
#                                  DELETE /users/:id(.:format)                                      users#destroy
#                      settlements GET    /settlements(.:format)                                    settlements#index
#                                  POST   /settlements(.:format)                                    settlements#create
#                   new_settlement GET    /settlements/new(.:format)                                settlements#new
#                  edit_settlement GET    /settlements/:id/edit(.:format)                           settlements#edit
#                       settlement GET    /settlements/:id(.:format)                                settlements#show
#                                  PATCH  /settlements/:id(.:format)                                settlements#update
#                                  PUT    /settlements/:id(.:format)                                settlements#update
#                                  DELETE /settlements/:id(.:format)                                settlements#destroy
#               settlement_partial POST   /settlements/:id/show_partial(.:format)                   settlements#show_partial
#           settlement_add_payment POST   /settlements/:id/add_payment(.:format)                    settlements#add_payment
#                                  GET    /expenses(.:format)                                       expenses#expenses
#                        oauth_new GET    /oauth/new(.:format)                                      opro/oauth/auth#new
#                  oauth_authorize POST   /oauth/authorize(.:format)                                opro/oauth/auth#create
#                      oauth_token POST   /oauth/token(.:format)                                    opro/oauth/token#create
#                oauth_client_apps GET    /oauth_client_apps(.:format)                              opro/oauth/client_app#index
#                                  POST   /oauth_client_apps(.:format)                              opro/oauth/client_app#create
#             new_oauth_client_app GET    /oauth_client_apps/new(.:format)                          opro/oauth/client_app#new
#            edit_oauth_client_app GET    /oauth_client_apps/:id/edit(.:format)                     opro/oauth/client_app#edit
#                 oauth_client_app GET    /oauth_client_apps/:id(.:format)                          opro/oauth/client_app#show
#                                  PATCH  /oauth_client_apps/:id(.:format)                          opro/oauth/client_app#update
#                                  PUT    /oauth_client_apps/:id(.:format)                          opro/oauth/client_app#update
#                                  DELETE /oauth_client_apps/:id(.:format)                          opro/oauth/client_app#destroy
#                       oauth_docs GET    /oauth_docs(.:format)                                     opro/oauth/docs#index
#                        oauth_doc GET    /oauth_docs/:id(.:format)                                 opro/oauth/docs#show
#                      oauth_tests GET    /oauth_tests(.:format)                                    opro/oauth/tests#index
#                                  POST   /oauth_tests(.:format)                                    opro/oauth/tests#create
#                       oauth_test GET    /oauth_tests/:id(.:format)                                opro/oauth/tests#show
#                                  DELETE /oauth_tests/:id(.:format)                                opro/oauth/tests#destroy
#                             root GET    /                                                         static_pages#home
#                            about GET    /about(.:format)                                          static_pages#about
#                         features GET    /features(.:format)                                       static_pages#features
#                     user_profile GET    /users/profile(.:format)                                  users#profile
#             update_user_password POST   /users/update_password(.:format)                          users#update_password
#

Rails.application.routes.draw do
  # get 'policies' => 'policies#index'
  devise_for :users

  resources :policies, except: [:new, :edit]
  resources :policies do
    post 'invitable_users' => 'policies#invitable_users', as: :invitable_users
    post 'add_users' => 'policies#add_users', as: :add_users
    post 'remove_users' => 'policies#remove_users', as: :remove_users
    patch 'update_users_configuration' => 'policies#update_user_configuration', as: :update_user_configuration
    post 'add_rule', to: 'policies#add_rule', as: :add_rule
    delete 'remove_rule', to: 'policies#remove_rule', as: :remove_rule
  end

  get 'organization_account' => 'organization_account#organization_account'

  # get 'policy' => 'organization_account#policy', as: :policy


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
    patch 'reimburse' => 'reports#reimburse', as: :reimburse
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

  resources :users do
    post 'user_details', to: 'users#user_details', as: :details
    patch 'update_user_team', to: 'users#update_team', as: :update_team
    post 'update_role', to: 'users#update_role', as: :update_role
  end

  resources :settlements
  post 'settlements/:id/show_partial' => 'settlements#show_partial', as: :settlement_partial
  post 'settlements/:id/add_payment' => 'settlements#add_payment', as: :settlement_add_payment
  get 'expenses' => 'expenses#expenses'

  mount_opro_oauth

  resources :receipts do

  end

  root 'static_pages#home'

  get 'about', to: 'static_pages#about'

  get 'features', to: 'static_pages#features'

  get 'users/profile', to: 'users#profile', as: :user_profile

  post 'users/update_password', to: 'users#update_password', as: :update_user_password



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
