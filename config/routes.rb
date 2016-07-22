# == Route Map
#
#                       Prefix Verb   URI Pattern                                         Controller#Action
#         organization_account GET    /organization_account(.:format)                     organization_account#organization_account
#                 user_profile GET    /user_profile(.:format)                             user_profile#user_profile
#                       people GET    /people(.:format)                                   people#people
#                      reports GET    /reports(.:format)                                  reports#index
#                              POST   /reports(.:format)                                  reports#create
#                       report GET    /reports/:id(.:format)                              reports#show
#                              PATCH  /reports/:id(.:format)                              reports#update
#                              PUT    /reports/:id(.:format)                              reports#update
#                              DELETE /reports/:id(.:format)                              reports#destroy
#                export_report GET    /export/report(.:format)                            export#report
#               report_comment POST   /reports/:report_id/comment(.:format)               reports#comment
#               report_retract PATCH  /reports/:report_id/retract(.:format)               reports#retract
#                report_submit PATCH  /reports/:report_id/submit(.:format)                reports#submit
#               report_approve PATCH  /reports/:report_id/approve(.:format)               reports#approve
#             report_unapprove PATCH  /reports/:report_id/unapprove(.:format)             reports#unapprove
#                report_reject PATCH  /reports/:report_id/reject(.:format)                reports#reject
#             report_reimburse PATCH  /reports/:report_id/reimburse(.:format)             reports#reimburse
# report_reimbursement_confirm PATCH  /reports/:report_id/reimbursement_confirm(.:format) reports#reimbursement_confirm
#          report_take_control PATCH  /reports/:report_id/take_control(.:format)          reports#take_control
#          report_add_expenses POST   /reports/:report_id/add_expenses(.:format)          reports#add_expenses
#       report_remove_expenses DELETE /reports/:report_id/remove_expenses(.:format)       reports#remove_expenses
#                              GET    /reports(.:format)                                  reports#index
#                              POST   /reports(.:format)                                  reports#create
#                   new_report GET    /reports/new(.:format)                              reports#new
#                  edit_report GET    /reports/:id/edit(.:format)                         reports#edit
#                              GET    /reports/:id(.:format)                              reports#show
#                              PATCH  /reports/:id(.:format)                              reports#update
#                              PUT    /reports/:id(.:format)                              reports#update
#                              DELETE /reports/:id(.:format)                              reports#destroy
#                     policies GET    /policies(.:format)                                 policies#index
#                              POST   /policies(.:format)                                 policies#create
#                       policy GET    /policies/:id(.:format)                             policies#show
#                              PATCH  /policies/:id(.:format)                             policies#update
#                              PUT    /policies/:id(.:format)                             policies#update
#                              DELETE /policies/:id(.:format)                             policies#destroy
#                    oauth_new GET    /oauth/new(.:format)                                opro/oauth/auth#new
#              oauth_authorize POST   /oauth/authorize(.:format)                          opro/oauth/auth#create
#                  oauth_token POST   /oauth/token(.:format)                              opro/oauth/token#create
#            oauth_client_apps GET    /oauth_client_apps(.:format)                        opro/oauth/client_app#index
#                              POST   /oauth_client_apps(.:format)                        opro/oauth/client_app#create
#         new_oauth_client_app GET    /oauth_client_apps/new(.:format)                    opro/oauth/client_app#new
#        edit_oauth_client_app GET    /oauth_client_apps/:id/edit(.:format)               opro/oauth/client_app#edit
#             oauth_client_app GET    /oauth_client_apps/:id(.:format)                    opro/oauth/client_app#show
#                              PATCH  /oauth_client_apps/:id(.:format)                    opro/oauth/client_app#update
#                              PUT    /oauth_client_apps/:id(.:format)                    opro/oauth/client_app#update
#                              DELETE /oauth_client_apps/:id(.:format)                    opro/oauth/client_app#destroy
#                   oauth_docs GET    /oauth_docs(.:format)                               opro/oauth/docs#index
#                    oauth_doc GET    /oauth_docs/:id(.:format)                           opro/oauth/docs#show
#                  oauth_tests GET    /oauth_tests(.:format)                              opro/oauth/tests#index
#                              POST   /oauth_tests(.:format)                              opro/oauth/tests#create
#                   oauth_test GET    /oauth_tests/:id(.:format)                          opro/oauth/tests#show
#                              DELETE /oauth_tests/:id(.:format)                          opro/oauth/tests#destroy
#                         root GET    /                                                   static_pages#home
#                        about GET    /about(.:format)                                    static_pages#about
#                     features GET    /features(.:format)                                 static_pages#features
#             new_user_session GET    /users/sign_in(.:format)                            devise/sessions#new
#                 user_session POST   /users/sign_in(.:format)                            devise/sessions#create
#         destroy_user_session DELETE /users/sign_out(.:format)                           devise/sessions#destroy
#                user_password POST   /users/password(.:format)                           devise/passwords#create
#            new_user_password GET    /users/password/new(.:format)                       devise/passwords#new
#           edit_user_password GET    /users/password/edit(.:format)                      devise/passwords#edit
#                              PATCH  /users/password(.:format)                           devise/passwords#update
#                              PUT    /users/password(.:format)                           devise/passwords#update
#     cancel_user_registration GET    /users/cancel(.:format)                             devise_invitable/registrations#cancel
#            user_registration POST   /users(.:format)                                    devise_invitable/registrations#create
#        new_user_registration GET    /users/sign_up(.:format)                            devise_invitable/registrations#new
#       edit_user_registration GET    /users/edit(.:format)                               devise_invitable/registrations#edit
#                              PATCH  /users(.:format)                                    devise_invitable/registrations#update
#                              PUT    /users(.:format)                                    devise_invitable/registrations#update
#                              DELETE /users(.:format)                                    devise_invitable/registrations#destroy
#            user_confirmation POST   /users/confirmation(.:format)                       devise/confirmations#create
#        new_user_confirmation GET    /users/confirmation/new(.:format)                   devise/confirmations#new
#                              GET    /users/confirmation(.:format)                       devise/confirmations#show
#                  user_unlock POST   /users/unlock(.:format)                             devise/unlocks#create
#              new_user_unlock GET    /users/unlock/new(.:format)                         devise/unlocks#new
#                              GET    /users/unlock(.:format)                             devise/unlocks#show
#       accept_user_invitation GET    /users/invitation/accept(.:format)                  devise/invitations#edit
#       remove_user_invitation GET    /users/invitation/remove(.:format)                  devise/invitations#destroy
#              user_invitation POST   /users/invitation(.:format)                         devise/invitations#create
#          new_user_invitation GET    /users/invitation/new(.:format)                     devise/invitations#new
#                              PATCH  /users/invitation(.:format)                         devise/invitations#update
#                              PUT    /users/invitation(.:format)                         devise/invitations#update
#

Rails.application.routes.draw do
  # get 'policies' => 'policies#index'
  resources :policies, except: [:new, :edit]
  resources :policies do
    post 'invitable_users' => 'policies#invitable_users', as: :invitable_users
    post 'add_users' => 'policies#add_users', as: :add_users
    post 'remove_users' => 'policies#remove_users', as: :remove_users
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
  end

  resources :expenses do
    post 'attach_receipt', to: 'expenses#attach_receipt'
    post 'detach_receipt', to: 'expenses#detach_receipt'

  end

  resources :settlements
  post 'settlements/:id/show_partial' => 'settlements#show_partial', as: :settlement_partial
  post 'settlements/:id/add_payment' => 'settlements#add_payment', as: :settlement_add_payment
  get 'expenses' => 'expenses#expenses'

  mount_opro_oauth

  root 'static_pages#home'

  get 'about', to: 'static_pages#about'

  get 'features', to: 'static_pages#features'

  get 'users/profile', to: 'users#profile', as: :user_profile

  post 'users/update_password', to: 'users#update_password', as: :update_user_password

  devise_for :users

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
  #     ends
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
