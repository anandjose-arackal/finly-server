# == Route Map
#
#                                                  Prefix Verb   URI Pattern                                                                     Controller#Action
#                       qukickbooks_configurations_create GET    /qukickbooks_configurations/create(.:format)                                    qukickbooks_configurations#create
#                       qukickbooks_configurations_update GET    /qukickbooks_configurations/update(.:format)                                    qukickbooks_configurations#update
#                         qukickbooks_configurations_show GET    /qukickbooks_configurations/show(.:format)                                      qukickbooks_configurations#show
#                                           accept_invite GET    /users/invitation/accept(.:format)                                              pending_invites#edit
#                                               crono_web        /crono                                                                          Crono::Web
#                                  new_admin_user_session GET    /admin_users/sign_in(.:format)                                                  admin_users/sessions#new
#                                      admin_user_session POST   /admin_users/sign_in(.:format)                                                  admin_users/sessions#create
#                              destroy_admin_user_session DELETE /admin_users/sign_out(.:format)                                                 admin_users/sessions#destroy
#                                     admin_user_password POST   /admin_users/password(.:format)                                                 devise/passwords#create
#                                 new_admin_user_password GET    /admin_users/password/new(.:format)                                             devise/passwords#new
#                                edit_admin_user_password GET    /admin_users/password/edit(.:format)                                            devise/passwords#edit
#                                                         PATCH  /admin_users/password(.:format)                                                 devise/passwords#update
#                                                         PUT    /admin_users/password(.:format)                                                 devise/passwords#update
#                     api_v1_configuration_category_index GET    /api/v1/configuration/category/index(.:format)                                  api/v1/configuration/category#index
#                           api_v1_configuration_category GET    /api/v1/configuration/category(.:format)                                        api/v1/configuration#category
#                                         email_processor POST   /email/incoming(.:format)                                                       griddler/emails#create
#                                        new_user_session GET    /users/sign_in(.:format)                                                        sessions#new
#                                            user_session POST   /users/sign_in(.:format)                                                        sessions#create
#                                    destroy_user_session DELETE /users/sign_out(.:format)                                                       sessions#destroy
#                                           user_password POST   /users/password(.:format)                                                       passwords#create
#                                       new_user_password GET    /users/password/new(.:format)                                                   passwords#new
#                                      edit_user_password GET    /users/password/edit(.:format)                                                  passwords#edit
#                                                         PATCH  /users/password(.:format)                                                       passwords#update
#                                                         PUT    /users/password(.:format)                                                       passwords#update
#                                cancel_user_registration GET    /users/cancel(.:format)                                                         devise_invitable/registrations#cancel
#                                       user_registration POST   /users(.:format)                                                                devise_invitable/registrations#create
#                                   new_user_registration GET    /users/sign_up(.:format)                                                        devise_invitable/registrations#new
#                                  edit_user_registration GET    /users/edit(.:format)                                                           devise_invitable/registrations#edit
#                                                         PATCH  /users(.:format)                                                                devise_invitable/registrations#update
#                                                         PUT    /users(.:format)                                                                devise_invitable/registrations#update
#                                                         DELETE /users(.:format)                                                                devise_invitable/registrations#destroy
#                                       user_confirmation POST   /users/confirmation(.:format)                                                   devise/confirmations#create
#                                   new_user_confirmation GET    /users/confirmation/new(.:format)                                               devise/confirmations#new
#                                                         GET    /users/confirmation(.:format)                                                   devise/confirmations#show
#                                             user_unlock POST   /users/unlock(.:format)                                                         devise/unlocks#create
#                                         new_user_unlock GET    /users/unlock/new(.:format)                                                     devise/unlocks#new
#                                                         GET    /users/unlock(.:format)                                                         devise/unlocks#show
#                                  accept_user_invitation GET    /users/invitation/accept(.:format)                                              devise/invitations#edit
#                                  remove_user_invitation GET    /users/invitation/remove(.:format)                                              devise/invitations#destroy
#                                         user_invitation POST   /users/invitation(.:format)                                                     devise/invitations#create
#                                     new_user_invitation GET    /users/invitation/new(.:format)                                                 devise/invitations#new
#                                                         PATCH  /users/invitation(.:format)                                                     devise/invitations#update
#                                                         PUT    /users/invitation(.:format)                                                     devise/invitations#update
#                                                         GET    /oauth/authorize/:code(.:format)                                                doorkeeper/authorizations#show
#                                     oauth_authorization GET    /oauth/authorize(.:format)                                                      doorkeeper/authorizations#new
#                                                         POST   /oauth/authorize(.:format)                                                      doorkeeper/authorizations#create
#                                                         DELETE /oauth/authorize(.:format)                                                      doorkeeper/authorizations#destroy
#                                             oauth_token POST   /oauth/token(.:format)                                                          oauth/token#create
#                                            oauth_revoke POST   /oauth/revoke(.:format)                                                         oauth/token#revoke
#                                      oauth_applications GET    /oauth/applications(.:format)                                                   doorkeeper/applications#index
#                                                         POST   /oauth/applications(.:format)                                                   doorkeeper/applications#create
#                                   new_oauth_application GET    /oauth/applications/new(.:format)                                               doorkeeper/applications#new
#                                  edit_oauth_application GET    /oauth/applications/:id/edit(.:format)                                          doorkeeper/applications#edit
#                                       oauth_application GET    /oauth/applications/:id(.:format)                                               doorkeeper/applications#show
#                                                         PATCH  /oauth/applications/:id(.:format)                                               doorkeeper/applications#update
#                                                         PUT    /oauth/applications/:id(.:format)                                               doorkeeper/applications#update
#                                                         DELETE /oauth/applications/:id(.:format)                                               doorkeeper/applications#destroy
#                           oauth_authorized_applications GET    /oauth/authorized_applications(.:format)                                        doorkeeper/authorized_applications#index
#                            oauth_authorized_application DELETE /oauth/authorized_applications/:id(.:format)                                    doorkeeper/authorized_applications#destroy
#                                        oauth_token_info GET    /oauth/token/info(.:format)                                                     doorkeeper/token_info#show
#                                         api_v0_expenses GET    /api/v0/expenses(.:format)                                                      api/v0/expenses#index
#                                                         POST   /api/v0/expenses(.:format)                                                      api/v0/expenses#create
#                                          api_v0_expense GET    /api/v0/expenses/:id(.:format)                                                  api/v0/expenses#show
#                                                         PATCH  /api/v0/expenses/:id(.:format)                                                  api/v0/expenses#update
#                                                         PUT    /api/v0/expenses/:id(.:format)                                                  api/v0/expenses#update
#                                                         DELETE /api/v0/expenses/:id(.:format)                                                  api/v0/expenses#destroy
#                                          api_v0_reports GET    /api/v0/reports(.:format)                                                       api/v0/reports#index
#                                                         POST   /api/v0/reports(.:format)                                                       api/v0/reports#create
#                                           api_v0_report GET    /api/v0/reports/:id(.:format)                                                   api/v0/reports#show
#                                                         PATCH  /api/v0/reports/:id(.:format)                                                   api/v0/reports#update
#                                                         PUT    /api/v0/reports/:id(.:format)                                                   api/v0/reports#update
#                                                         DELETE /api/v0/reports/:id(.:format)                                                   api/v0/reports#destroy
#                                   api_v0_report_comment POST   /api/v0/reports/:report_id/comment(.:format)                                    api/v0/reports#comment
#                                   api_v0_report_retract PATCH  /api/v0/reports/:report_id/retract(.:format)                                    api/v0/reports#retract
#                                    api_v0_report_submit PATCH  /api/v0/reports/:report_id/submit(.:format)                                     api/v0/reports#submit
#                                   api_v0_report_approve PATCH  /api/v0/reports/:report_id/approve(.:format)                                    api/v0/reports#approve
#                                 api_v0_report_unapprove PATCH  /api/v0/reports/:report_id/unapprove(.:format)                                  api/v0/reports#unapprove
#                                    api_v0_report_reject PATCH  /api/v0/reports/:report_id/reject(.:format)                                     api/v0/reports#reject
#                        api_v0_report_settlement_confirm PATCH  /api/v0/reports/:report_id/settlement_confirm(.:format)                         api/v0/reports#settlement_confirm
#                              api_v0_report_take_control PATCH  /api/v0/reports/:report_id/take_control(.:format)                               api/v0/reports#take_control
#                              api_v0_report_add_expenses POST   /api/v0/reports/:report_id/add_expenses(.:format)                               api/v0/reports#add_expenses
#                           api_v0_report_remove_expenses DELETE /api/v0/reports/:report_id/remove_expenses(.:format)                            api/v0/reports#remove_expenses
#                            api_v0_report_reject_expense PATCH  /api/v0/reports/:report_id/reject_expense(.:format)                             api/v0/reports#reject_expense
#                             api_v0_report_assign_policy POST   /api/v0/reports/:report_id/assign_policy(.:format)                              api/v0/reports#assign_policy
#                                                         GET    /api/v0/reports(.:format)                                                       api/v0/reports#index
#                                                         POST   /api/v0/reports(.:format)                                                       api/v0/reports#create
#                                       new_api_v0_report GET    /api/v0/reports/new(.:format)                                                   api/v0/reports#new
#                                      edit_api_v0_report GET    /api/v0/reports/:id/edit(.:format)                                              api/v0/reports#edit
#                                                         GET    /api/v0/reports/:id(.:format)                                                   api/v0/reports#show
#                                                         PATCH  /api/v0/reports/:id(.:format)                                                   api/v0/reports#update
#                                                         PUT    /api/v0/reports/:id(.:format)                                                   api/v0/reports#update
#                                                         DELETE /api/v0/reports/:id(.:format)                                                   api/v0/reports#destroy
#                                         api_v0_receipts GET    /api/v0/receipts(.:format)                                                      api/v0/receipts#index
#                                                         POST   /api/v0/receipts(.:format)                                                      api/v0/receipts#create
#                                          api_v0_receipt PATCH  /api/v0/receipts/:id(.:format)                                                  api/v0/receipts#update
#                                                         PUT    /api/v0/receipts/:id(.:format)                                                  api/v0/receipts#update
#                                                         DELETE /api/v0/receipts/:id(.:format)                                                  api/v0/receipts#destroy
#                     api_v0_receipt_expense_from_receipt POST   /api/v0/receipts/:receipt_id/expense_from_receipt(.:format)                     api/v0/receipts#expense_from_receipt
#                                                         GET    /api/v0/receipts(.:format)                                                      api/v0/receipts#index
#                                                         POST   /api/v0/receipts(.:format)                                                      api/v0/receipts#create
#                                      new_api_v0_receipt GET    /api/v0/receipts/new(.:format)                                                  api/v0/receipts#new
#                                     edit_api_v0_receipt GET    /api/v0/receipts/:id/edit(.:format)                                             api/v0/receipts#edit
#                                                         GET    /api/v0/receipts/:id(.:format)                                                  api/v0/receipts#show
#                                                         PATCH  /api/v0/receipts/:id(.:format)                                                  api/v0/receipts#update
#                                                         PUT    /api/v0/receipts/:id(.:format)                                                  api/v0/receipts#update
#                                                         DELETE /api/v0/receipts/:id(.:format)                                                  api/v0/receipts#destroy
#                         api_v0_configuration_categories GET    /api/v0/configuration/categories(.:format)                                      api/v0/configuration/category#index
#                       api_v0_configuration_gcm_register POST   /api/v0/configuration/gcm/register(.:format)                                    api/v0/configuration/gcm#create
#                     api_v0_configuration_gcm_unregister POST   /api/v0/configuration/gcm/unregister(.:format)                                  api/v0/configuration/gcm#delete
#                                         api_v1_expenses GET    /api/v1/expenses(.:format)                                                      api/v1/expenses#index
#                                                         POST   /api/v1/expenses(.:format)                                                      api/v1/expenses#create
#                                          api_v1_expense GET    /api/v1/expenses/:id(.:format)                                                  api/v1/expenses#show
#                                                         PATCH  /api/v1/expenses/:id(.:format)                                                  api/v1/expenses#update
#                                                         PUT    /api/v1/expenses/:id(.:format)                                                  api/v1/expenses#update
#                                                         DELETE /api/v1/expenses/:id(.:format)                                                  api/v1/expenses#destroy
#                                          api_v1_reports GET    /api/v1/reports(.:format)                                                       api/v1/reports#index
#                                                         POST   /api/v1/reports(.:format)                                                       api/v1/reports#create
#                                           api_v1_report GET    /api/v1/reports/:id(.:format)                                                   api/v1/reports#show
#                                                         PATCH  /api/v1/reports/:id(.:format)                                                   api/v1/reports#update
#                                                         PUT    /api/v1/reports/:id(.:format)                                                   api/v1/reports#update
#                                                         DELETE /api/v1/reports/:id(.:format)                                                   api/v1/reports#destroy
#                                   api_v1_report_comment POST   /api/v1/reports/:report_id/comment(.:format)                                    api/v1/reports#comment
#                                                         GET    /api/v1/reports(.:format)                                                       api/v1/reports#index
#                                                         POST   /api/v1/reports(.:format)                                                       api/v1/reports#create
#                                       new_api_v1_report GET    /api/v1/reports/new(.:format)                                                   api/v1/reports#new
#                                      edit_api_v1_report GET    /api/v1/reports/:id/edit(.:format)                                              api/v1/reports#edit
#                                                         GET    /api/v1/reports/:id(.:format)                                                   api/v1/reports#show
#                                                         PATCH  /api/v1/reports/:id(.:format)                                                   api/v1/reports#update
#                                                         PUT    /api/v1/reports/:id(.:format)                                                   api/v1/reports#update
#                                                         DELETE /api/v1/reports/:id(.:format)                                                   api/v1/reports#destroy
#                                   api_v1_money_requests GET    /api/v1/money_requests(.:format)                                                api/v1/money_requests#index
#                                                         POST   /api/v1/money_requests(.:format)                                                api/v1/money_requests#create
#                                    api_v1_money_request GET    /api/v1/money_requests/:id(.:format)                                            api/v1/money_requests#show
#                                                         PATCH  /api/v1/money_requests/:id(.:format)                                            api/v1/money_requests#update
#                                                         PUT    /api/v1/money_requests/:id(.:format)                                            api/v1/money_requests#update
#                                                         DELETE /api/v1/money_requests/:id(.:format)                                            api/v1/money_requests#destroy
#                            api_v1_money_request_comment POST   /api/v1/money_requests/:money_request_id/comment(.:format)                      api/v1/money_requests#comment
#                                                         GET    /api/v1/money_requests(.:format)                                                api/v1/money_requests#index
#                                                         POST   /api/v1/money_requests(.:format)                                                api/v1/money_requests#create
#                                new_api_v1_money_request GET    /api/v1/money_requests/new(.:format)                                            api/v1/money_requests#new
#                               edit_api_v1_money_request GET    /api/v1/money_requests/:id/edit(.:format)                                       api/v1/money_requests#edit
#                                                         GET    /api/v1/money_requests/:id(.:format)                                            api/v1/money_requests#show
#                                                         PATCH  /api/v1/money_requests/:id(.:format)                                            api/v1/money_requests#update
#                                                         PUT    /api/v1/money_requests/:id(.:format)                                            api/v1/money_requests#update
#                                                         DELETE /api/v1/money_requests/:id(.:format)                                            api/v1/money_requests#destroy
#                                         api_v1_receipts GET    /api/v1/receipts(.:format)                                                      api/v1/receipts#index
#                                                         POST   /api/v1/receipts(.:format)                                                      api/v1/receipts#create
#                                          api_v1_receipt PATCH  /api/v1/receipts/:id(.:format)                                                  api/v1/receipts#update
#                                                         PUT    /api/v1/receipts/:id(.:format)                                                  api/v1/receipts#update
#                                                         DELETE /api/v1/receipts/:id(.:format)                                                  api/v1/receipts#destroy
#                                 api_v1_receipt_add_note POST   /api/v1/receipts/:receipt_id/add_note(.:format)                                 api/v1/receipts#add_note
#                     api_v1_receipt_expense_from_receipt POST   /api/v1/receipts/:receipt_id/expense_from_receipt(.:format)                     api/v1/receipts#expense_from_receipt
#                                                         GET    /api/v1/receipts(.:format)                                                      api/v1/receipts#index
#                                                         POST   /api/v1/receipts(.:format)                                                      api/v1/receipts#create
#                                      new_api_v1_receipt GET    /api/v1/receipts/new(.:format)                                                  api/v1/receipts#new
#                                     edit_api_v1_receipt GET    /api/v1/receipts/:id/edit(.:format)                                             api/v1/receipts#edit
#                                                         GET    /api/v1/receipts/:id(.:format)                                                  api/v1/receipts#show
#                                                         PATCH  /api/v1/receipts/:id(.:format)                                                  api/v1/receipts#update
#                                                         PUT    /api/v1/receipts/:id(.:format)                                                  api/v1/receipts#update
#                                                         DELETE /api/v1/receipts/:id(.:format)                                                  api/v1/receipts#destroy
#                                            api_v1_users GET    /api/v1/users(.:format)                                                         api/v1/users#index
#                                             api_v1_user GET    /api/v1/users/:id(.:format)                                                     api/v1/users#show
#                                api_v1_user_user_summary GET    /api/v1/users/:user_id/summary(.:format)                                        api/v1/users#summary
#                                                         GET    /api/v1/users(.:format)                                                         api/v1/users#index
#                                                         POST   /api/v1/users(.:format)                                                         api/v1/users#create
#                                         new_api_v1_user GET    /api/v1/users/new(.:format)                                                     api/v1/users#new
#                                        edit_api_v1_user GET    /api/v1/users/:id/edit(.:format)                                                api/v1/users#edit
#                                                         GET    /api/v1/users/:id(.:format)                                                     api/v1/users#show
#                                                         PATCH  /api/v1/users/:id(.:format)                                                     api/v1/users#update
#                                                         PUT    /api/v1/users/:id(.:format)                                                     api/v1/users#update
#                                                         DELETE /api/v1/users/:id(.:format)                                                     api/v1/users#destroy
#                             api_v1_cards_balance_update POST   /api/v1/cards/balance/update(.:format)                                          api/v1/cards#update_balance
#                              api_v1_cards_status_update POST   /api/v1/cards/status/update(.:format)                                           api/v1/cards#update_status
#                         api_v1_configuration_categories GET    /api/v1/configuration/categories(.:format)                                      api/v1/configuration/category#index
#                       api_v1_configuration_gcm_register POST   /api/v1/configuration/gcm/register(.:format)                                    api/v1/configuration/gcm#create
#                     api_v1_configuration_gcm_unregister POST   /api/v1/configuration/gcm/unregister(.:format)                                  api/v1/configuration/gcm#delete
#                                         api_v1_balances GET    /api/v1/balances(.:format)                                                      api/v1/users#balance
#                          api_v1_available_expense_types GET    /api/v1/available_expense_types(.:format)                                       api/v1/expenses#available_expense_types
#                                                  api_v1 GET    /api/v1/kyc/:id(.:format)                                                       api/v1/kyc/user#show
#                                                         POST   /api/v1/kyc/:id(.:format)                                                       api/v1/kyc/user#update
#                                      mobile_v0_expenses GET    /mobile/v0/expenses(.:format)                                                   mobile/v0/expenses#index
#                                                         POST   /mobile/v0/expenses(.:format)                                                   mobile/v0/expenses#create
#                                       mobile_v0_expense GET    /mobile/v0/expenses/:id(.:format)                                               mobile/v0/expenses#show
#                                                         PATCH  /mobile/v0/expenses/:id(.:format)                                               mobile/v0/expenses#update
#                                                         PUT    /mobile/v0/expenses/:id(.:format)                                               mobile/v0/expenses#update
#                                                         DELETE /mobile/v0/expenses/:id(.:format)                                               mobile/v0/expenses#destroy
#                                       mobile_v0_reports GET    /mobile/v0/reports(.:format)                                                    mobile/v0/reports#index
#                                                         POST   /mobile/v0/reports(.:format)                                                    mobile/v0/reports#create
#                                        mobile_v0_report GET    /mobile/v0/reports/:id(.:format)                                                mobile/v0/reports#show
#                                                         PATCH  /mobile/v0/reports/:id(.:format)                                                mobile/v0/reports#update
#                                                         PUT    /mobile/v0/reports/:id(.:format)                                                mobile/v0/reports#update
#                                                         DELETE /mobile/v0/reports/:id(.:format)                                                mobile/v0/reports#destroy
#                                mobile_v0_report_comment POST   /mobile/v0/reports/:report_id/comment(.:format)                                 mobile/v0/reports#comment
#                                mobile_v0_report_retract PATCH  /mobile/v0/reports/:report_id/retract(.:format)                                 mobile/v0/reports#retract
#                                 mobile_v0_report_submit PATCH  /mobile/v0/reports/:report_id/submit(.:format)                                  mobile/v0/reports#submit
#                                mobile_v0_report_approve PATCH  /mobile/v0/reports/:report_id/approve(.:format)                                 mobile/v0/reports#approve
#                              mobile_v0_report_unapprove PATCH  /mobile/v0/reports/:report_id/unapprove(.:format)                               mobile/v0/reports#unapprove
#                                 mobile_v0_report_reject PATCH  /mobile/v0/reports/:report_id/reject(.:format)                                  mobile/v0/reports#reject
#                     mobile_v0_report_settlement_confirm PATCH  /mobile/v0/reports/:report_id/settlement_confirm(.:format)                      mobile/v0/reports#settlement_confirm
#                           mobile_v0_report_take_control PATCH  /mobile/v0/reports/:report_id/take_control(.:format)                            mobile/v0/reports#take_control
#                           mobile_v0_report_add_expenses POST   /mobile/v0/reports/:report_id/add_expenses(.:format)                            mobile/v0/reports#add_expenses
#                        mobile_v0_report_remove_expenses DELETE /mobile/v0/reports/:report_id/remove_expenses(.:format)                         mobile/v0/reports#remove_expenses
#                         mobile_v0_report_reject_expense PATCH  /mobile/v0/reports/:report_id/reject_expense(.:format)                          mobile/v0/reports#reject_expense
#                          mobile_v0_report_assign_policy POST   /mobile/v0/reports/:report_id/assign_policy(.:format)                           mobile/v0/reports#assign_policy
#                                                         GET    /mobile/v0/reports(.:format)                                                    mobile/v0/reports#index
#                                                         POST   /mobile/v0/reports(.:format)                                                    mobile/v0/reports#create
#                                    new_mobile_v0_report GET    /mobile/v0/reports/new(.:format)                                                mobile/v0/reports#new
#                                   edit_mobile_v0_report GET    /mobile/v0/reports/:id/edit(.:format)                                           mobile/v0/reports#edit
#                                                         GET    /mobile/v0/reports/:id(.:format)                                                mobile/v0/reports#show
#                                                         PATCH  /mobile/v0/reports/:id(.:format)                                                mobile/v0/reports#update
#                                                         PUT    /mobile/v0/reports/:id(.:format)                                                mobile/v0/reports#update
#                                                         DELETE /mobile/v0/reports/:id(.:format)                                                mobile/v0/reports#destroy
#                                      mobile_v0_receipts GET    /mobile/v0/receipts(.:format)                                                   mobile/v0/receipts#index
#                                                         POST   /mobile/v0/receipts(.:format)                                                   mobile/v0/receipts#create
#                                       mobile_v0_receipt PATCH  /mobile/v0/receipts/:id(.:format)                                               mobile/v0/receipts#update
#                                                         PUT    /mobile/v0/receipts/:id(.:format)                                               mobile/v0/receipts#update
#                                                         DELETE /mobile/v0/receipts/:id(.:format)                                               mobile/v0/receipts#destroy
#                  mobile_v0_receipt_expense_from_receipt POST   /mobile/v0/receipts/:receipt_id/expense_from_receipt(.:format)                  mobile/v0/receipts#expense_from_receipt
#                                                         GET    /mobile/v0/receipts(.:format)                                                   mobile/v0/receipts#index
#                                                         POST   /mobile/v0/receipts(.:format)                                                   mobile/v0/receipts#create
#                                   new_mobile_v0_receipt GET    /mobile/v0/receipts/new(.:format)                                               mobile/v0/receipts#new
#                                  edit_mobile_v0_receipt GET    /mobile/v0/receipts/:id/edit(.:format)                                          mobile/v0/receipts#edit
#                                                         GET    /mobile/v0/receipts/:id(.:format)                                               mobile/v0/receipts#show
#                                                         PATCH  /mobile/v0/receipts/:id(.:format)                                               mobile/v0/receipts#update
#                                                         PUT    /mobile/v0/receipts/:id(.:format)                                               mobile/v0/receipts#update
#                                                         DELETE /mobile/v0/receipts/:id(.:format)                                               mobile/v0/receipts#destroy
#                      mobile_v0_configuration_categories GET    /mobile/v0/configuration/categories(.:format)                                   mobile/v0/configuration/category#index
#                    mobile_v0_configuration_gcm_register POST   /mobile/v0/configuration/gcm/register(.:format)                                 mobile/v0/configuration/gcm#create
#                  mobile_v0_configuration_gcm_unregister POST   /mobile/v0/configuration/gcm/unregister(.:format)                               mobile/v0/configuration/gcm#delete
#                                          mobile_v1_auth POST   /mobile/v1/auth(.:format)                                                       mobile/v1/token#create
#                        mobile_v1_configuration_category GET    /mobile/v1/configuration/category(.:format)                                     mobile/v1/configuration#category
#                                      mobile_v1_expenses GET    /mobile/v1/expenses(.:format)                                                   mobile/v1/expenses#index
#                                                         POST   /mobile/v1/expenses(.:format)                                                   mobile/v1/expenses#create
#                                       mobile_v1_expense GET    /mobile/v1/expenses/:id(.:format)                                               mobile/v1/expenses#show
#                                                         PATCH  /mobile/v1/expenses/:id(.:format)                                               mobile/v1/expenses#update
#                                                         PUT    /mobile/v1/expenses/:id(.:format)                                               mobile/v1/expenses#update
#                                                         DELETE /mobile/v1/expenses/:id(.:format)                                               mobile/v1/expenses#destroy
#                                       mobile_v1_reports GET    /mobile/v1/reports(.:format)                                                    mobile/v1/reports#index
#                                                         POST   /mobile/v1/reports(.:format)                                                    mobile/v1/reports#create
#                                        mobile_v1_report GET    /mobile/v1/reports/:id(.:format)                                                mobile/v1/reports#show
#                                                         PATCH  /mobile/v1/reports/:id(.:format)                                                mobile/v1/reports#update
#                                                         PUT    /mobile/v1/reports/:id(.:format)                                                mobile/v1/reports#update
#                                                         DELETE /mobile/v1/reports/:id(.:format)                                                mobile/v1/reports#destroy
#                                mobile_v1_report_comment POST   /mobile/v1/reports/:report_id/comment(.:format)                                 mobile/v1/reports#comment
#                                                         GET    /mobile/v1/reports(.:format)                                                    mobile/v1/reports#index
#                                                         POST   /mobile/v1/reports(.:format)                                                    mobile/v1/reports#create
#                                    new_mobile_v1_report GET    /mobile/v1/reports/new(.:format)                                                mobile/v1/reports#new
#                                   edit_mobile_v1_report GET    /mobile/v1/reports/:id/edit(.:format)                                           mobile/v1/reports#edit
#                                                         GET    /mobile/v1/reports/:id(.:format)                                                mobile/v1/reports#show
#                                                         PATCH  /mobile/v1/reports/:id(.:format)                                                mobile/v1/reports#update
#                                                         PUT    /mobile/v1/reports/:id(.:format)                                                mobile/v1/reports#update
#                                                         DELETE /mobile/v1/reports/:id(.:format)                                                mobile/v1/reports#destroy
#                                mobile_v1_money_requests GET    /mobile/v1/money_requests(.:format)                                             mobile/v1/money_requests#index
#                                                         POST   /mobile/v1/money_requests(.:format)                                             mobile/v1/money_requests#create
#                                 mobile_v1_money_request GET    /mobile/v1/money_requests/:id(.:format)                                         mobile/v1/money_requests#show
#                                                         PATCH  /mobile/v1/money_requests/:id(.:format)                                         mobile/v1/money_requests#update
#                                                         PUT    /mobile/v1/money_requests/:id(.:format)                                         mobile/v1/money_requests#update
#                                                         DELETE /mobile/v1/money_requests/:id(.:format)                                         mobile/v1/money_requests#destroy
#                         mobile_v1_money_request_comment POST   /mobile/v1/money_requests/:money_request_id/comment(.:format)                   mobile/v1/money_requests#comment
#                                                         GET    /mobile/v1/money_requests(.:format)                                             mobile/v1/money_requests#index
#                                                         POST   /mobile/v1/money_requests(.:format)                                             mobile/v1/money_requests#create
#                             new_mobile_v1_money_request GET    /mobile/v1/money_requests/new(.:format)                                         mobile/v1/money_requests#new
#                            edit_mobile_v1_money_request GET    /mobile/v1/money_requests/:id/edit(.:format)                                    mobile/v1/money_requests#edit
#                                                         GET    /mobile/v1/money_requests/:id(.:format)                                         mobile/v1/money_requests#show
#                                                         PATCH  /mobile/v1/money_requests/:id(.:format)                                         mobile/v1/money_requests#update
#                                                         PUT    /mobile/v1/money_requests/:id(.:format)                                         mobile/v1/money_requests#update
#                                                         DELETE /mobile/v1/money_requests/:id(.:format)                                         mobile/v1/money_requests#destroy
#                                      mobile_v1_receipts GET    /mobile/v1/receipts(.:format)                                                   mobile/v1/receipts#index
#                                                         POST   /mobile/v1/receipts(.:format)                                                   mobile/v1/receipts#create
#                                       mobile_v1_receipt PATCH  /mobile/v1/receipts/:id(.:format)                                               mobile/v1/receipts#update
#                                                         PUT    /mobile/v1/receipts/:id(.:format)                                               mobile/v1/receipts#update
#                                                         DELETE /mobile/v1/receipts/:id(.:format)                                               mobile/v1/receipts#destroy
#                              mobile_v1_receipt_add_note POST   /mobile/v1/receipts/:receipt_id/add_note(.:format)                              mobile/v1/receipts#add_note
#                  mobile_v1_receipt_expense_from_receipt POST   /mobile/v1/receipts/:receipt_id/expense_from_receipt(.:format)                  mobile/v1/receipts#expense_from_receipt
#                                                         GET    /mobile/v1/receipts(.:format)                                                   mobile/v1/receipts#index
#                                                         POST   /mobile/v1/receipts(.:format)                                                   mobile/v1/receipts#create
#                                   new_mobile_v1_receipt GET    /mobile/v1/receipts/new(.:format)                                               mobile/v1/receipts#new
#                                  edit_mobile_v1_receipt GET    /mobile/v1/receipts/:id/edit(.:format)                                          mobile/v1/receipts#edit
#                                                         GET    /mobile/v1/receipts/:id(.:format)                                               mobile/v1/receipts#show
#                                                         PATCH  /mobile/v1/receipts/:id(.:format)                                               mobile/v1/receipts#update
#                                                         PUT    /mobile/v1/receipts/:id(.:format)                                               mobile/v1/receipts#update
#                                                         DELETE /mobile/v1/receipts/:id(.:format)                                               mobile/v1/receipts#destroy
#                                         mobile_v1_users GET    /mobile/v1/users(.:format)                                                      mobile/v1/users#index
#                                          mobile_v1_user GET    /mobile/v1/users/:id(.:format)                                                  mobile/v1/users#show
#                             mobile_v1_user_user_summary GET    /mobile/v1/users/:user_id/summary(.:format)                                     mobile/v1/users#summary
#                                                         GET    /mobile/v1/users(.:format)                                                      mobile/v1/users#index
#                                                         POST   /mobile/v1/users(.:format)                                                      mobile/v1/users#create
#                                      new_mobile_v1_user GET    /mobile/v1/users/new(.:format)                                                  mobile/v1/users#new
#                                     edit_mobile_v1_user GET    /mobile/v1/users/:id/edit(.:format)                                             mobile/v1/users#edit
#                                                         GET    /mobile/v1/users/:id(.:format)                                                  mobile/v1/users#show
#                                                         PATCH  /mobile/v1/users/:id(.:format)                                                  mobile/v1/users#update
#                                                         PUT    /mobile/v1/users/:id(.:format)                                                  mobile/v1/users#update
#                                                         DELETE /mobile/v1/users/:id(.:format)                                                  mobile/v1/users#destroy
#                          mobile_v1_cards_balance_update POST   /mobile/v1/cards/balance/update(.:format)                                       mobile/v1/cards#update_balance
#                           mobile_v1_cards_status_update POST   /mobile/v1/cards/status/update(.:format)                                        mobile/v1/cards#update_status
#                  mobile_v1_configuration_category_index GET    /mobile/v1/configuration/category/index(.:format)                               mobile/v1/configuration/category#index
#                      mobile_v1_configuration_categories GET    /mobile/v1/configuration/categories(.:format)                                   mobile/v1/configuration/category#index
#                    mobile_v1_configuration_gcm_register POST   /mobile/v1/configuration/gcm/register(.:format)                                 mobile/v1/configuration/gcm#create
#                  mobile_v1_configuration_gcm_unregister POST   /mobile/v1/configuration/gcm/unregister(.:format)                               mobile/v1/configuration/gcm#delete
#                                      mobile_v1_balances GET    /mobile/v1/balances(.:format)                                                   mobile/v1/users#balance
#                       mobile_v1_available_expense_types GET    /mobile/v1/available_expense_types(.:format)                                    mobile/v1/expenses#available_expense_types
#                                               mobile_v1 GET    /mobile/v1/kyc/:id(.:format)                                                    mobile/v1/kyc/user#show
#                                                         POST   /mobile/v1/kyc/:id(.:format)                                                    mobile/v1/kyc/user#update
#                                                         POST   /mobile/v1/kyc/:id/submit(.:format)                                             mobile/v1/kyc/user#submit
#                                                         POST   /mobile/v1/kyc/:id/update_and_submit(.:format)                                  mobile/v1/kyc/user#update_and_submit
#                                                         POST   /mobile/v1/kyc/:id/retract(.:format)                                            mobile/v1/kyc/user#retract
#                                  mobile_v1_transactions GET    /mobile/v1/transactions(.:format)                                               mobile/v1/cards#transactions
#                                        mobile_v1_lookup POST   /mobile/v1/lookup(.:format)                                                     mobile/v1/users#lookup
#                         mobile_v1_send_verification_otp POST   /mobile/v1/send_verification_otp(.:format)                                      mobile/v1/users#send_verification_otp
#                               mobile_v1_verify_user_otp POST   /mobile/v1/verify_user_otp(.:format)                                            mobile/v1/users#verify_user_otp
#                                          chrome_v1_auth POST   /chrome/v1/auth(.:format)                                                       chrome/v1/token#create
#                                                         DELETE /chrome/v1/auth(.:format)                                                       chrome/v1/token#destroy
#                        chrome_v1_expenses_configuration POST   /chrome/v1/expenses/configuration(.:format)                                     chrome/v1/expenses#configuration
#                                      chrome_v1_expenses POST   /chrome/v1/expenses(.:format)                                                   chrome/v1/expenses#create
#                                       chrome_v1_expense PATCH  /chrome/v1/expenses/:id(.:format)                                               chrome/v1/expenses#update
#                                                         PUT    /chrome/v1/expenses/:id(.:format)                                               chrome/v1/expenses#update
#                                                         DELETE /chrome/v1/expenses/:id(.:format)                                               chrome/v1/expenses#destroy
#                                               chrome_v1 POST   /chrome/v1/emails/:id(.:format)                                                 chrome/v1/receipt_email#show
#                                          api_fm_v1_auth POST   /api/fm/v1/auth(.:format)                                                       api/fm/v1/token#create
#                                                         DELETE /api/fm/v1/auth(.:format)                                                       api/fm/v1/token#destroy
#                                         api_fm_v1_users GET    /api/fm/v1/users(.:format)                                                      api/fm/v1/users#index
#                                                         POST   /api/fm/v1/users(.:format)                                                      api/fm/v1/users#create
#                                          api_fm_v1_user GET    /api/fm/v1/users/:id(.:format)                                                  api/fm/v1/users#show
#                                                         PATCH  /api/fm/v1/users/:id(.:format)                                                  api/fm/v1/users#update
#                                                         PUT    /api/fm/v1/users/:id(.:format)                                                  api/fm/v1/users#update
#                                         api_fm_v1_cards GET    /api/fm/v1/cards(.:format)                                                      api/fm/v1/cards#index
#                                          api_fm_v1_card GET    /api/fm/v1/cards/:id(.:format)                                                  api/fm/v1/cards#show
#                             api_fm_v1_card_transactions GET    /api/fm/v1/cards/:card_id/transactions(.:format)                                api/fm/v1/cards#transactions
#                                   api_fm_v1_card_status PATCH  /api/fm/v1/cards/:card_id/status(.:format)                                      api/fm/v1/cards#update_status
#                                                         GET    /api/fm/v1/cards(.:format)                                                      api/fm/v1/cards#index
#                                                         POST   /api/fm/v1/cards(.:format)                                                      api/fm/v1/cards#create
#                                      new_api_fm_v1_card GET    /api/fm/v1/cards/new(.:format)                                                  api/fm/v1/cards#new
#                                     edit_api_fm_v1_card GET    /api/fm/v1/cards/:id/edit(.:format)                                             api/fm/v1/cards#edit
#                                                         GET    /api/fm/v1/cards/:id(.:format)                                                  api/fm/v1/cards#show
#                                                         PATCH  /api/fm/v1/cards/:id(.:format)                                                  api/fm/v1/cards#update
#                                                         PUT    /api/fm/v1/cards/:id(.:format)                                                  api/fm/v1/cards#update
#                                                         DELETE /api/fm/v1/cards/:id(.:format)                                                  api/fm/v1/cards#destroy
#                                  api_fm_v1_funds_credit POST   /api/fm/v1/funds/credit(.:format)                                               api/fm/v1/funds#credit
#                                   api_fm_v1_funds_debit POST   /api/fm/v1/funds/debit(.:format)                                                api/fm/v1/funds#debit
#                 transcriber_transcribed_expenses_create POST   /transcriber/expenses/create(.:format)                                          transcriber/receipts#create_expense
#                 transcriber_transcribed_expenses_update PATCH  /transcriber/expenses/:id/update(.:format)                                      transcriber/receipts#update_expense
#                    transcriber_transcribed_receipt_show GET    /transcriber/expenses/:id/show(.:format)                                        transcriber/receipts#show
#                      transcriber_untranscribed_receipts GET    /transcriber/companies/:id(.:format)                                            transcriber/companies#show
#                                   transcriber_companies GET    /transcriber/companies(.:format)                                                transcriber/companies#index
#                                    transcriber_expenses GET    /transcriber/expenses(.:format)                                                 transcriber/expenses#index
#                                                         POST   /transcriber/expenses(.:format)                                                 transcriber/expenses#create
#                                 new_transcriber_expense GET    /transcriber/expenses/new(.:format)                                             transcriber/expenses#new
#                                edit_transcriber_expense GET    /transcriber/expenses/:id/edit(.:format)                                        transcriber/expenses#edit
#                                     transcriber_expense GET    /transcriber/expenses/:id(.:format)                                             transcriber/expenses#show
#                                                         PATCH  /transcriber/expenses/:id(.:format)                                             transcriber/expenses#update
#                                                         PUT    /transcriber/expenses/:id(.:format)                                             transcriber/expenses#update
#                                                         DELETE /transcriber/expenses/:id(.:format)                                             transcriber/expenses#destroy
#                                                         GET    /transcriber/companies(.:format)                                                transcriber/companies#index
#                                                         POST   /transcriber/companies(.:format)                                                transcriber/companies#create
#                                 new_transcriber_company GET    /transcriber/companies/new(.:format)                                            transcriber/companies#new
#                                edit_transcriber_company GET    /transcriber/companies/:id/edit(.:format)                                       transcriber/companies#edit
#                                     transcriber_company GET    /transcriber/companies/:id(.:format)                                            transcriber/companies#show
#                                                         PATCH  /transcriber/companies/:id(.:format)                                            transcriber/companies#update
#                                                         PUT    /transcriber/companies/:id(.:format)                                            transcriber/companies#update
#                                                         DELETE /transcriber/companies/:id(.:format)                                            transcriber/companies#destroy
#                                    transcriber_receipts GET    /transcriber/receipts(.:format)                                                 transcriber/receipts#index
#                                                         POST   /transcriber/receipts(.:format)                                                 transcriber/receipts#create
#                                 new_transcriber_receipt GET    /transcriber/receipts/new(.:format)                                             transcriber/receipts#new
#                                edit_transcriber_receipt GET    /transcriber/receipts/:id/edit(.:format)                                        transcriber/receipts#edit
#                                     transcriber_receipt GET    /transcriber/receipts/:id(.:format)                                             transcriber/receipts#show
#                                                         PATCH  /transcriber/receipts/:id(.:format)                                             transcriber/receipts#update
#                                                         PUT    /transcriber/receipts/:id(.:format)                                             transcriber/receipts#update
#                                                         DELETE /transcriber/receipts/:id(.:format)                                             transcriber/receipts#destroy
#                         admin_users_company_dcode_check POST   /admin_users/companies/:company_id/dcode_check(.:format)                        admin_users/companies#check_dcode
#                      admin_users_company_configure_payu POST   /admin_users/companies/:company_id/configure_payu(.:format)                     admin_users/companies#configure_payu
#                                   admin_users_companies GET    /admin_users/companies(.:format)                                                admin_users/companies#index
#                                                         POST   /admin_users/companies(.:format)                                                admin_users/companies#create
#                                 new_admin_users_company GET    /admin_users/companies/new(.:format)                                            admin_users/companies#new
#                                edit_admin_users_company GET    /admin_users/companies/:id/edit(.:format)                                       admin_users/companies#edit
#                                     admin_users_company GET    /admin_users/companies/:id(.:format)                                            admin_users/companies#show
#                                                         PATCH  /admin_users/companies/:id(.:format)                                            admin_users/companies#update
#                                                         PUT    /admin_users/companies/:id(.:format)                                            admin_users/companies#update
#                                                         DELETE /admin_users/companies/:id(.:format)                                            admin_users/companies#destroy
#                               admin_users_company_types GET    /admin_users/company_types(.:format)                                            admin_users/companies#company_types
#                          admin_users_user_update_status PATCH  /admin_users/users/:user_id/update_status(.:format)                             admin_users/users#update_status
#                         admin_users_user_update_mapping PATCH  /admin_users/users/:user_id/update_mapping(.:format)                            admin_users/users#update_mapping
#                        admin_users_user_destroy_mapping DELETE /admin_users/users/:user_id/destroy_mapping(.:format)                           admin_users/users#destroy_mapping
#                           admin_users_user_update_panel PATCH  /admin_users/users/:user_id/update_panel(.:format)                              admin_users/users#update_panel
#                                       admin_users_users GET    /admin_users/users(.:format)                                                    admin_users/users#index
#                                                         POST   /admin_users/users(.:format)                                                    admin_users/users#create
#                                    new_admin_users_user GET    /admin_users/users/new(.:format)                                                admin_users/users#new
#                                   edit_admin_users_user GET    /admin_users/users/:id/edit(.:format)                                           admin_users/users#edit
#                                        admin_users_user GET    /admin_users/users/:id(.:format)                                                admin_users/users#show
#                                                         PATCH  /admin_users/users/:id(.:format)                                                admin_users/users#update
#                                                         PUT    /admin_users/users/:id(.:format)                                                admin_users/users#update
#                                                         DELETE /admin_users/users/:id(.:format)                                                admin_users/users#destroy
#                                     admin_users_welcome POST   /admin_users/welcome(.:format)                                                  admin_users/users#admin_welcome
#                                    admin_users_set_role POST   /admin_users/users/set_role(.:format)                                           admin_users/users#set_role
#                                      admin_users_lookup GET    /admin_users/lookup(.:format)                                                   admin_users/users#lookup
#                                      admin_users_import POST   /admin_users/import(.:format)                                                   admin_users/users#import
#                                 admin_users_temp_import GET    /admin_users/temp_import(.:format)                                              admin_users/users#temp_import
#                                    admin_users_expenses GET    /admin_users/expenses(.:format)                                                 admin_users/expenses#index
#                                                         POST   /admin_users/expenses(.:format)                                                 admin_users/expenses#create
#                                 new_admin_users_expense GET    /admin_users/expenses/new(.:format)                                             admin_users/expenses#new
#                                edit_admin_users_expense GET    /admin_users/expenses/:id/edit(.:format)                                        admin_users/expenses#edit
#                                     admin_users_expense GET    /admin_users/expenses/:id(.:format)                                             admin_users/expenses#show
#                                                         PATCH  /admin_users/expenses/:id(.:format)                                             admin_users/expenses#update
#                                                         PUT    /admin_users/expenses/:id(.:format)                                             admin_users/expenses#update
#                                                         DELETE /admin_users/expenses/:id(.:format)                                             admin_users/expenses#destroy
#                                  admin_users_card_block PATCH  /admin_users/cards/:card_id/block(.:format)                                     admin_users/cards#block
#                                       admin_users_cards GET    /admin_users/cards(.:format)                                                    admin_users/cards#index
#                                                         POST   /admin_users/cards(.:format)                                                    admin_users/cards#create
#                                    new_admin_users_card GET    /admin_users/cards/new(.:format)                                                admin_users/cards#new
#                                   edit_admin_users_card GET    /admin_users/cards/:id/edit(.:format)                                           admin_users/cards#edit
#                                        admin_users_card GET    /admin_users/cards/:id(.:format)                                                admin_users/cards#show
#                                                         PATCH  /admin_users/cards/:id(.:format)                                                admin_users/cards#update
#                                                         PUT    /admin_users/cards/:id(.:format)                                                admin_users/cards#update
#                                                         DELETE /admin_users/cards/:id(.:format)                                                admin_users/cards#destroy
#                                admin_users_import_cards POST   /admin_users/import_cards(.:format)                                             admin_users/cards#import
#                          admin_users_kyc_company_reject PATCH  /admin_users/kyc/companies/:company_id/reject(.:format)                         admin_users/kyc/companies#reject
#                         admin_users_kyc_company_confirm PATCH  /admin_users/kyc/companies/:company_id/confirm(.:format)                        admin_users/kyc/companies#confirm
#                               admin_users_kyc_companies GET    /admin_users/kyc/companies(.:format)                                            admin_users/kyc/companies#index
#                                                         POST   /admin_users/kyc/companies(.:format)                                            admin_users/kyc/companies#create
#                             new_admin_users_kyc_company GET    /admin_users/kyc/companies/new(.:format)                                        admin_users/kyc/companies#new
#                            edit_admin_users_kyc_company GET    /admin_users/kyc/companies/:id/edit(.:format)                                   admin_users/kyc/companies#edit
#                                 admin_users_kyc_company GET    /admin_users/kyc/companies/:id(.:format)                                        admin_users/kyc/companies#show
#                                                         PATCH  /admin_users/kyc/companies/:id(.:format)                                        admin_users/kyc/companies#update
#                                                         PUT    /admin_users/kyc/companies/:id(.:format)                                        admin_users/kyc/companies#update
#                                                         DELETE /admin_users/kyc/companies/:id(.:format)                                        admin_users/kyc/companies#destroy
#                                   admin_users_kyc_users GET    /admin_users/kyc/users(.:format)                                                admin_users/kyc/users#index
#                           admin_users_kyc_users_history GET    /admin_users/kyc/users/history(.:format)                                        admin_users/kyc/users#history_index
#                           admin_users_kyc_users_approve POST   /admin_users/kyc/users/approve(.:format)                                        admin_users/kyc/users#approve
#                            admin_users_kyc_users_reject POST   /admin_users/kyc/users/reject(.:format)                                         admin_users/kyc/users#reject
#                  admin_users_kyc_users_mark_as_upgraded POST   /admin_users/kyc/users/mark_as_upgraded(.:format)                               admin_users/kyc/users#mark_as_upgraded
#                                         admin_users_kyc PATCH  /admin_users/kyc/users/:id(.:format)                                            admin_users/kyc/users#update
#                                                         GET    /admin_users/kyc/users/export(.:format)                                         admin_users/kyc/users#export
#                                                         GET    /admin_users/kyc/users/export/kycs(.:format)                                    admin_users/kyc/users#download_kycs
#                                  admin_users_agreements GET    /admin_users/agreements(.:format)                                               admin_users/agreements#index
#                                                         POST   /admin_users/agreements(.:format)                                               admin_users/agreements#create
#                          admin_users_verifier_companies GET    /admin_users/verifier/companies(.:format)                                       admin_users/verifier/company#index
#                  admin_users_verifier_companies_history GET    /admin_users/verifier/companies/history(.:format)                               admin_users/verifier/company#history_index
#                        admin_users_card_assign_requests GET    /admin_users/card_assign_requests(.:format)                                     admin_users/card_assign_requests#index
#                admin_users_card_assign_requests_history GET    /admin_users/card_assign_requests/history(.:format)                             admin_users/card_assign_requests#history_index
#                admin_users_card_assign_requests_approve POST   /admin_users/card_assign_requests/approve(.:format)                             admin_users/card_assign_requests#approve
#                 admin_users_card_assign_requests_reject POST   /admin_users/card_assign_requests/reject(.:format)                              admin_users/card_assign_requests#reject
#          admin_users_card_assign_requests_mark_assigned POST   /admin_users/card_assign_requests/mark_assigned(.:format)                       admin_users/card_assign_requests#mark_as_assigned
# admin_users_card_assign_requests_mark_assigned_upgraded POST   /admin_users/card_assign_requests/mark_assigned_upgraded(.:format)              admin_users/card_assign_requests#mark_as_assigned_upgraded
#                                             admin_users PATCH  /admin_users/card_assign_requests/:id(.:format)                                 admin_users/card_assign_requests#update
#                                                         GET    /admin_users/card_assign_requests/export(.:format)                              admin_users/card_assign_requests#export
#                                                         GET    /admin_users/card_assign_requests/export/kycs(.:format)                         admin_users/card_assign_requests#download_kycs
#                   admin_users_card_assign_requests_edit GET    /admin_users/card_assign_requests/edit(.:format)                                admin_users/card_assign_requests#edit
#                                      admin_users_search POST   /admin_users/call_center/search(.:format)                                       admin_users/call_center/users#search
#                                              admin_menu GET    /admin_menus(.:format)                                                          admin_users/users#admin_menus
#                                               junk_show GET    /junk/show(.:format)                                                            junk#show
#                                               menu_data GET    /menu_data(.:format)                                                            users#menu_data
#                              admin_oauth_token_generate POST   /admin/oauth/token(.:format)                                                    admin_users/oauth/token#create {:format=>"json"}
#                                    preview_registration POST   /welcome/preview(.:format)                                                      registrations#preview
#                                       resources_details POST   /resources_details(.:format)                                                    registrations#resource_requests
#                                      resources_download GET    /download_resource(.:format)                                                    registrations#resources_download
#                                  policies_expense_rules GET    /policies/expense_rules(.:format)                                               policies#expense_rules
#                                   policies_budget_rules GET    /policies/budget_rules(.:format)                                                policies#budget_rules
#                                 policies_policy_members GET    /policies/policy_members(.:format)                                              policies#policy_members
#                                    policies_create_rule GET    /policies/create_rule(.:format)                                                 policies#create_rule
#                         policies_policy_member_settings GET    /policies/policy_member_settings(.:format)                                      policies#policy_member_settings
#                                        policies_details GET    /policies/details(.:format)                                                     policies#details
#                                       policies_personal GET    /policies/personal(.:format)                                                    policies#show_personal
#                                                policies GET    /policies(.:format)                                                             policies#index
#                                                         POST   /policies(.:format)                                                             policies#create
#                                                  policy GET    /policies/:id(.:format)                                                         policies#show
#                                                         PATCH  /policies/:id(.:format)                                                         policies#update
#                                                         PUT    /policies/:id(.:format)                                                         policies#update
#                                                         DELETE /policies/:id(.:format)                                                         policies#destroy
#                                  policy_invitable_users POST   /policies/:policy_id/invitable_users(.:format)                                  policies#invitable_users
#                                        policy_add_users POST   /policies/:policy_id/add_users(.:format)                                        policies#add_users
#                                     policy_remove_users POST   /policies/:policy_id/remove_users(.:format)                                     policies#remove_users
#                        policy_update_user_configuration PATCH  /policies/:policy_id/update_users_configuration(.:format)                       policies#update_user_configuration
#                                  policy_destroy_mapping DELETE /policies/:policy_id/remove_mapping/:mapping_id(.:format)                       policies#destrot_mapping
#                                         policy_add_rule POST   /policies/:policy_id/add_rule(.:format)                                         rules#create
#                                      policy_remove_rule DELETE /policies/:policy_id/remove_rule(.:format)                                      rules#destroy
#                                      policy_description GET    /policies/:policy_id/description(.:format)                                      policies#show_description
#                                                         GET    /policies(.:format)                                                             policies#index
#                                                         POST   /policies(.:format)                                                             policies#create
#                                              new_policy GET    /policies/new(.:format)                                                         policies#new
#                                             edit_policy GET    /policies/:id/edit(.:format)                                                    policies#edit
#                                                         GET    /policies/:id(.:format)                                                         policies#show
#                                                         PATCH  /policies/:id(.:format)                                                         policies#update
#                                                         PUT    /policies/:id(.:format)                                                         policies#update
#                                                         DELETE /policies/:id(.:format)                                                         policies#destroy
#                                              categories GET    /categories(.:format)                                                           categories#index
#                                                         POST   /categories(.:format)                                                           categories#create
#                                            new_category GET    /categories/new(.:format)                                                       categories#new
#                                           edit_category GET    /categories/:id/edit(.:format)                                                  categories#edit
#                                                category GET    /categories/:id(.:format)                                                       categories#show
#                                                         PATCH  /categories/:id(.:format)                                                       categories#update
#                                                         PUT    /categories/:id(.:format)                                                       categories#update
#                                                         DELETE /categories/:id(.:format)                                                       categories#destroy
#                                      export_preferences GET    /export_preferences(.:format)                                                   export_preferences#index
#                                                         POST   /export_preferences(.:format)                                                   export_preferences#create
#                                   new_export_preference GET    /export_preferences/new(.:format)                                               export_preferences#new
#                                  edit_export_preference GET    /export_preferences/:id/edit(.:format)                                          export_preferences#edit
#                                       export_preference GET    /export_preferences/:id(.:format)                                               export_preferences#show
#                                                         PATCH  /export_preferences/:id(.:format)                                               export_preferences#update
#                                                         PUT    /export_preferences/:id(.:format)                                               export_preferences#update
#                                                         DELETE /export_preferences/:id(.:format)                                               export_preferences#destroy
#                                       card_restrictions GET    /card_restrictions(.:format)                                                    card_restrictions#index
#                                                         POST   /card_restrictions(.:format)                                                    card_restrictions#create
#                                    new_card_restriction GET    /card_restrictions/new(.:format)                                                card_restrictions#new
#                                   edit_card_restriction GET    /card_restrictions/:id/edit(.:format)                                           card_restrictions#edit
#                                        card_restriction GET    /card_restrictions/:id(.:format)                                                card_restrictions#show
#                                                         PATCH  /card_restrictions/:id(.:format)                                                card_restrictions#update
#                                                         PUT    /card_restrictions/:id(.:format)                                                card_restrictions#update
#                                                         DELETE /card_restrictions/:id(.:format)                                                card_restrictions#destroy
#                                        companies_notify GET    /companies/notify(.:format)                                                     companies#notify
#                                     company_add_balance POST   /companies/:company_id/add_balance(.:format)                                    companies#add_balance
#                                               companies GET    /companies(.:format)                                                            companies#index
#                                                         POST   /companies(.:format)                                                            companies#create
#                                             new_company GET    /companies/new(.:format)                                                        companies#new
#                                            edit_company GET    /companies/:id/edit(.:format)                                                   companies#edit
#                                                 company GET    /companies/:id(.:format)                                                        companies#show
#                                                         PATCH  /companies/:id(.:format)                                                        companies#update
#                                                         PUT    /companies/:id(.:format)                                                        companies#update
#                                                         DELETE /companies/:id(.:format)                                                        companies#destroy
#                      organization_account_policies_list GET    /organization_account/policies_list(.:format)                                   organization_account#policies_list
#                         organization_account_categories GET    /organization_account/categories(.:format)                                      organization_account#categories
#                 organization_account_export_preferences GET    /organization_account/export_preferences(.:format)                              organization_account#export_preferences
#                                            add_category POST   /add_category(.:format)                                                         organization_account#add_category
#                                         remove_category DELETE /remove_category(.:format)                                                      organization_account#remove_category
#                                update_export_preference PATCH  /export/:id/update(.:format)                                                    organization_account#update_export_column
#                                        add_export_field POST   /add_export_field(.:format)                                                     organization_account#add_export_column
#                                     delete_export_field DELETE /remove_export_field(.:format)                                                  organization_account#remove_export_column
#                                                  people GET    /people(.:format)                                                               people#people
#                                           verify_mobile GET    /users/verify(.:format)                                                         otp#edit
#                                    update_mobile_number POST   /otp/update(.:format)                                                           otp#update
#                                              verify_otp POST   /otp/verify(.:format)                                                           otp#verify
#                                              resend_otp POST   /otp/resend(.:format)                                                           otp#resend
#                                            card_details POST   /cards/details(.:format)                                                        cards#details
#                                          update_balance POST   /cards/update_balance(.:format)                                                 cards#update_balance
#                                      update_card_status POST   /cards/update_status(.:format)                                                  cards#update_status
#                                             assign_card PATCH  /cards/assign(.:format)                                                         cards#assign
#                                   cancel_assign_request PATCH  /cards/assign/:id/cancel(.:format)                                              cards#cancel_assign
#                                        unassigned_cards GET    /cards/unassigned(.:format)                                                     cards#unassigned
#                                                 reports GET    /reports(.:format)                                                              reports#index
#                                                         POST   /reports(.:format)                                                              reports#create
#                                                  report GET    /reports/:id(.:format)                                                          reports#show
#                                                         PATCH  /reports/:id(.:format)                                                          reports#update
#                                                         PUT    /reports/:id(.:format)                                                          reports#update
#                                                         DELETE /reports/:id(.:format)                                                          reports#destroy
#                                           export_report GET    /export/report(.:format)                                                        export#report
#                                          report_comment POST   /reports/:report_id/comment(.:format)                                           reports#comment
#                                          report_retract PATCH  /reports/:report_id/retract(.:format)                                           reports#retract
#                                           report_submit PATCH  /reports/:report_id/submit(.:format)                                            reports#submit
#                                          report_approve PATCH  /reports/:report_id/approve(.:format)                                           reports#approve
#                                        report_unapprove PATCH  /reports/:report_id/unapprove(.:format)                                         reports#unapprove
#                                           report_reject PATCH  /reports/:report_id/reject(.:format)                                            reports#reject
#                                   report_reject_expense PATCH  /reports/:report_id/reject_expense(.:format)                                    reports#reject_expense
#                               report_settlement_confirm PATCH  /reports/:report_id/settlement_confirm(.:format)                                reports#settlement_confirm
#                                     report_take_control PATCH  /reports/:report_id/take_control(.:format)                                      reports#take_control
#                                     report_add_expenses POST   /reports/:report_id/add_expenses(.:format)                                      reports#add_expenses
#                                  report_remove_expenses DELETE /reports/:report_id/remove_expenses(.:format)                                   reports#remove_expenses
#                          report_toggle_receipt_hardcopy POST   /reports/:report_id/toggle_receipt_hardcopy(.:format)                           reports#toggle_receipt_hardcopy
#                                                         GET    /reports(.:format)                                                              reports#index
#                                                         POST   /reports(.:format)                                                              reports#create
#                                              new_report GET    /reports/new(.:format)                                                          reports#new
#                                             edit_report GET    /reports/:id/edit(.:format)                                                     reports#edit
#                                                         GET    /reports/:id(.:format)                                                          reports#show
#                                                         PATCH  /reports/:id(.:format)                                                          reports#update
#                                                         PUT    /reports/:id(.:format)                                                          reports#update
#                                                         DELETE /reports/:id(.:format)                                                          reports#destroy
#                                    reports_bulk_approve POST   /reports/bulk_approve(.:format)                                                 reports#bulk_approve
#                                     money_request_index GET    /money_request(.:format)                                                        money_request#index
#                                                         POST   /money_request(.:format)                                                        money_request#create
#                                           money_request GET    /money_request/:id(.:format)                                                    money_request#show
#                                                         PATCH  /money_request/:id(.:format)                                                    money_request#update
#                                                         PUT    /money_request/:id(.:format)                                                    money_request#update
#                                                         DELETE /money_request/:id(.:format)                                                    money_request#destroy
#                                   money_request_comment POST   /money_request/:money_request_id/comment(.:format)                              money_request#comment
#                                                         GET    /money_request(.:format)                                                        money_request#index
#                                                         POST   /money_request(.:format)                                                        money_request#create
#                                       new_money_request GET    /money_request/new(.:format)                                                    money_request#new
#                                      edit_money_request GET    /money_request/:id/edit(.:format)                                               money_request#edit
#                                                         GET    /money_request/:id(.:format)                                                    money_request#show
#                                                         PATCH  /money_request/:id(.:format)                                                    money_request#update
#                                                         PUT    /money_request/:id(.:format)                                                    money_request#update
#                                                         DELETE /money_request/:id(.:format)                                                    money_request#destroy
#                                                expenses DELETE /expenses(.:format)                                                             expenses#destroy
#                                  expense_attach_receipt POST   /expenses/:expense_id/attach_receipt(.:format)                                  expenses#attach_receipt
#                                  expense_detach_receipt POST   /expenses/:expense_id/detach_receipt(.:format)                                  expenses#detach_receipt
#                                     expense_add_receipt POST   /expenses/:expense_id/add_receipt(.:format)                                     expenses#add_receipt
#                                            expense_mark PATCH  /expenses/:expense_id/mark(.:format)                                            expenses#mark
#                                          expense_unmark PATCH  /expenses/:expense_id/unmark(.:format)                                          expenses#unmark
#                                      expense_duplicates GET    /expenses/:expense_id/duplicates(.:format)                                      expenses#duplicates
#                                                         GET    /expenses(.:format)                                                             expenses#index
#                                                         POST   /expenses(.:format)                                                             expenses#create
#                                             new_expense GET    /expenses/new(.:format)                                                         expenses#new
#                                            edit_expense GET    /expenses/:id/edit(.:format)                                                    expenses#edit
#                                                 expense GET    /expenses/:id(.:format)                                                         expenses#show
#                                                         PATCH  /expenses/:id(.:format)                                                         expenses#update
#                                                         PUT    /expenses/:id(.:format)                                                         expenses#update
#                                                         DELETE /expenses/:id(.:format)                                                         expenses#destroy
#                                     expenses_unreported POST   /expenses/unreported(.:format)                                                  expenses#unreported
#                                        receipt_add_note POST   /receipts/:receipt_id/add_note(.:format)                                        receipts#add_note
#                            receipt_enable_transcription PATCH  /receipts/:receipt_id/enable(.:format)                                          receipts#enable_transcription
#                           receipt_disable_transcription PATCH  /receipts/:receipt_id/disable(.:format)                                         receipts#disable_transcription
#                                                receipts GET    /receipts(.:format)                                                             receipts#index
#                                                         POST   /receipts(.:format)                                                             receipts#create
#                                             new_receipt GET    /receipts/new(.:format)                                                         receipts#new
#                                            edit_receipt GET    /receipts/:id/edit(.:format)                                                    receipts#edit
#                                                 receipt GET    /receipts/:id(.:format)                                                         receipts#show
#                                                         PATCH  /receipts/:id(.:format)                                                         receipts#update
#                                                         PUT    /receipts/:id(.:format)                                                         receipts#update
#                                                         DELETE /receipts/:id(.:format)                                                         receipts#destroy
#                                    expense_from_receipt POST   /expense_from_receipt(.:format)                                                 receipts#expense_from_receipt
#                                      users_get_managers GET    /users/get_managers(.:format)                                                   users#get_managers
#                                      users_user_profile GET    /users/user_profile(.:format)                                                   users#user_profile
#                                      users_user_balance GET    /users/user_balance(.:format)                                                   users#user_balance
#                                     users_user_security GET    /users/user_security(.:format)                                                  users#user_security
#                                                  lookup GET    /lookup(.:format)                                                               users#lookup
#                                   send_verification_otp POST   /send_verification_otp(.:format)                                                users#send_verification_otp
#                                         verify_user_otp POST   /verify_user_otp(.:format)                                                      users#verify_user_otp
#                                                   users GET    /users(.:format)                                                                users#index
#                                                         POST   /users(.:format)                                                                users#create
#                                                    user GET    /users/:id(.:format)                                                            users#show
#                                                         PATCH  /users/:id(.:format)                                                            users#update
#                                                         PUT    /users/:id(.:format)                                                            users#update
#                                                         DELETE /users/:id(.:format)                                                            users#destroy
#                                       user_user_summary GET    /users/:user_id/summary(.:format)                                               users#summary
#                                            user_details POST   /users/:user_id/user_details(.:format)                                          users#user_details
#                                        user_update_team PATCH  /users/:user_id/update_user_team(.:format)                                      users#update_team
#                                        user_update_role PATCH  /users/:user_id/update_role(.:format)                                           users#update_user_role
#                                            user_profile GET    /users/:user_id/profile(.:format)                                               users#profile
#                                    user_update_password POST   /users/:user_id/update_password(.:format)                                       users#update_password
#                                            user_balance GET    /users/:user_id/balance(.:format)                                               users#balance
#                          user_verify_reset_password_otp GET    /users/:user_id/verify_reset_otp(.:format)                                      users#verify_reset_password_otp
#                                                         GET    /users(.:format)                                                                users#index
#                                                         POST   /users(.:format)                                                                users#create
#                                                new_user GET    /users/new(.:format)                                                            users#new
#                                               edit_user GET    /users/:id/edit(.:format)                                                       users#edit
#                                                         GET    /users/:id(.:format)                                                            users#show
#                                                         PATCH  /users/:id(.:format)                                                            users#update
#                                                         PUT    /users/:id(.:format)                                                            users#update
#                                                         DELETE /users/:id(.:format)                                                            users#destroy
#                                 available_expense_types GET    /available_expense_types(.:format)                                              users#available_expense_types
#                                             user_import POST   /import(.:format)                                                               users#import
#                                       superadmin_import POST   /superadmin_import(.:format)                                                    admin/companies#import
#                                     initiate_activation GET    /pending_invites/initiate_activation(.:format)                                  pending_invites#initiate_activation
#                                       activate_employee GET    /pending_invites/activate_employee(.:format)                                    pending_invites#activate_employee
#                                                send_otp GET    /pending_invites/send_otp(.:format)                                             pending_invites#send_otp
#                              manager_activation_sign_up PATCH  /pending_invites/manager_sign_up(.:format)                                      pending_invites#manager_sign_up
#                                 update_default_password POST   /users/update_default_password(.:format)                                        users#update_default_password
#                                   edit_default_password GET    /edit_default_password(.:format)                                                users#edit_default_password
#                                         pending_invites POST   /pending_invites(.:format)                                                      pending_invites#create
#                                     edit_pending_invite GET    /pending_invites/:id/edit(.:format)                                             pending_invites#edit
#                                          pending_invite PATCH  /pending_invites/:id(.:format)                                                  pending_invites#update
#                                                         PUT    /pending_invites/:id(.:format)                                                  pending_invites#update
#                                                         DELETE /pending_invites/:id(.:format)                                                  pending_invites#destroy
#                                   pending_invite_accept PATCH  /pending_invites/:pending_invite_id/accept(.:format)                            pending_invites#accept
#                                                         GET    /pending_invites(.:format)                                                      pending_invites#index
#                                                         POST   /pending_invites(.:format)                                                      pending_invites#create
#                                      new_pending_invite GET    /pending_invites/new(.:format)                                                  pending_invites#new
#                                                         GET    /pending_invites/:id/edit(.:format)                                             pending_invites#edit
#                                                         GET    /pending_invites/:id(.:format)                                                  pending_invites#show
#                                                         PATCH  /pending_invites/:id(.:format)                                                  pending_invites#update
#                                                         PUT    /pending_invites/:id(.:format)                                                  pending_invites#update
#                                                         DELETE /pending_invites/:id(.:format)                                                  pending_invites#destroy
#                                     settlements_summary GET    /settlements/summary(.:format)                                                  settlements#summary
#                                             settlements GET    /settlements(.:format)                                                          settlements#index
#                                                         POST   /settlements(.:format)                                                          settlements#create
#                                          new_settlement GET    /settlements/new(.:format)                                                      settlements#new
#                                         edit_settlement GET    /settlements/:id/edit(.:format)                                                 settlements#edit
#                                              settlement GET    /settlements/:id(.:format)                                                      settlements#show
#                                                         PATCH  /settlements/:id(.:format)                                                      settlements#update
#                                                         PUT    /settlements/:id(.:format)                                                      settlements#update
#                                                         DELETE /settlements/:id(.:format)                                                      settlements#destroy
#                                  settlement_add_payment POST   /settlements/:id/add_payment(.:format)                                          settlements#add_payment
#                         expense_type_configuration_show GET    /expense_type_configurations(.:format)                                          expense_types_configuration#show
#                       expense_type_configuration_update PATCH  /expense_type_configurations(.:format)                                          expense_types_configuration#update
#                                               per_diems GET    /per_diems(.:format)                                                            per_diems#index
#                                                         POST   /per_diems(.:format)                                                            per_diems#create
#                                            new_per_diem GET    /per_diems/new(.:format)                                                        per_diems#new
#                                           edit_per_diem GET    /per_diems/:id/edit(.:format)                                                   per_diems#edit
#                                                per_diem GET    /per_diems/:id(.:format)                                                        per_diems#show
#                                                         PATCH  /per_diems/:id(.:format)                                                        per_diems#update
#                                                         PUT    /per_diems/:id(.:format)                                                        per_diems#update
#                                                         DELETE /per_diems/:id(.:format)                                                        per_diems#destroy
#                                       card_transactions GET    /card_transactions(.:format)                                                    card_transactions#index
#                                                         POST   /card_transactions(.:format)                                                    card_transactions#create
#                                    new_card_transaction GET    /card_transactions/new(.:format)                                                card_transactions#new
#                                   edit_card_transaction GET    /card_transactions/:id/edit(.:format)                                           card_transactions#edit
#                                        card_transaction GET    /card_transactions/:id(.:format)                                                card_transactions#show
#                                                         PATCH  /card_transactions/:id(.:format)                                                card_transactions#update
#                                                         PUT    /card_transactions/:id(.:format)                                                card_transactions#update
#                                                         DELETE /card_transactions/:id(.:format)                                                card_transactions#destroy
#                                         atm_withdrawals GET    /atm_withdrawals(.:format)                                                      card_transactions#atm_withdrawals
#                                                 refunds GET    /refunds(.:format)                                                              card_transactions#refunds
#                                  cancelled_transactions GET    /cancelled_against_transactions/:expense_id(.:format)                           card_transactions#cancelled_transactions
#                      statements_company_balance_summary GET    /statements/company_balance_summary(.:format)                                   statements#company_balance_summary
#                 statements_company_transactions_summary GET    /statements/company_transactions_summary(.:format)                              statements#company_transactions_summary
#                     statements_company_policies_summary GET    /statements/company_policies_summary(.:format)                                  statements#company_policies_summary
#                                                         GET    /statements/:id/summary(.:format)                                               statements#summary
#                                        export_statement GET    /export/:id/statements(.:format)                                                export#statement
#                                              statements GET    /statements(.:format)                                                           statements#index
#                                                         POST   /statements(.:format)                                                           statements#create
#                                           new_statement GET    /statements/new(.:format)                                                       statements#new
#                                          edit_statement GET    /statements/:id/edit(.:format)                                                  statements#edit
#                                               statement GET    /statements/:id(.:format)                                                       statements#show
#                                                         PATCH  /statements/:id(.:format)                                                       statements#update
#                                                         PUT    /statements/:id(.:format)                                                       statements#update
#                                                         DELETE /statements/:id(.:format)                                                       statements#destroy
#                                                    root GET    /                                                                               home#index
#                                                 welcome GET    /welcome(.:format)                                                              home#welcome
#                                                   about GET    /about(.:format)                                                                home#about
#                                               resources GET    /resources(.:format)                                                            home#resources
#                                   autocomplete_merchant GET    /autocomplete/merchant(.:format)                                                autocomplete#merchant
#                                       autocomplete_user GET    /autocomplete/user(.:format)                                                    autocomplete#user
#                                       autocomplete_card GET    /autocomplete/card(.:format)                                                    autocomplete#card
#                                     external_url_report GET    /external/reports/:id(.:format)                                                 external_url#report
#                              external_url_money_request GET    /external/requests/:id(.:format)                                                external_url#money_request
#                                 external_url_settlement GET    /external/settlements/:id(.:format)                                             external_url#payment
#                                external_url_transaction GET    /external/transaction/:id(.:format)                                             external_url#transaction
#                                               analytics GET    /analytics(.:format)                                                            analytics#show
#                                                         GET    /companies/notify(.:format)                                                     companies#notify
#                                           notifications GET    /notifications(.:format)                                                        notifications#index
#                                    notifications_unread GET    /notifications/unread(.:format)                                                 notifications#unread
#                             notifications_mark_all_read GET    /notifications/mark_all_read(.:format)                                          notifications#mark_all_read
#                                                    faqs GET    /faqs(.:format)                                                                 faqs#index
#                                                feedback POST   /feedback(.:format)                                                             feedback#create
#                                         menu_data_cards GET    /menu_data_cards(.:format)                                                      expense_types_configuration#menu_data_cards
#                                      menu_data_disburse GET    /menu_data_disburse(.:format)                                                   expense_types_configuration#menu_data_disburse
#                                      menu_data_payments GET    /menu_data_payments(.:format)                                                   expense_types_configuration#menu_data_payments
#                                            cards_orders GET    /cards/orders(.:format)                                                         orders/order_cards#index
#                                                         GET    /cards/orders/:id(.:format)                                                     orders/order_cards#show
#                                                         DELETE /cards/orders/:id(.:format)                                                     orders/order_cards#destroy
#                                 cards_meal_process_file POST   /cards/meal/process_file(.:format)                                              benefits/meal_cards#process_file
#                                       cards_meal_orders POST   /cards/meal/orders(.:format)                                                    benefits/meal_cards#create
#                                                         PATCH  /cards/meal/orders(.:format)                                                    benefits/meal_cards#update
#                                                         GET    /cards/meal/orders(.:format)                                                    benefits/meal_cards#index
#                                                         GET    /cards/meal/orders/:id(.:format)                                                benefits/meal_cards#show
#                                                         DELETE /cards/meal/orders/:id(.:format)                                                benefits/meal_cards#destroy
#                              cards_medical_process_file POST   /cards/medical/process_file(.:format)                                           benefits/medical_cards#process_file
#                                    cards_medical_orders POST   /cards/medical/orders(.:format)                                                 benefits/medical_cards#create
#                                                         PATCH  /cards/medical/orders(.:format)                                                 benefits/medical_cards#update
#                                                         GET    /cards/medical/orders(.:format)                                                 benefits/medical_cards#index
#                                                         GET    /cards/medical/orders/:id(.:format)                                             benefits/medical_cards#show
#                                                         DELETE /cards/medical/orders/:id(.:format)                                             benefits/medical_cards#destroy
#                              cards_expense_process_file POST   /cards/expense/process_file(.:format)                                           benefits/expense_cards#process_file
#                                    cards_expense_orders POST   /cards/expense/orders(.:format)                                                 benefits/expense_cards#create
#                                                         PATCH  /cards/expense/orders(.:format)                                                 benefits/expense_cards#update
#                                                         GET    /cards/expense/orders(.:format)                                                 benefits/expense_cards#index
#                                                         GET    /cards/expense/orders/:id(.:format)                                             benefits/expense_cards#show
#                                                         DELETE /cards/expense/orders/:id(.:format)                                             benefits/expense_cards#destroy
#                        cards_reimbursement_process_file POST   /cards/reimbursement/process_file(.:format)                                     benefits/reimbursement_cards#process_file
#                              cards_reimbursement_orders POST   /cards/reimbursement/orders(.:format)                                           benefits/reimbursement_cards#create
#                                                         PATCH  /cards/reimbursement/orders(.:format)                                           benefits/reimbursement_cards#update
#                                                         GET    /cards/reimbursement/orders(.:format)                                           benefits/reimbursement_cards#index
#                                                         GET    /cards/reimbursement/orders/:id(.:format)                                       benefits/reimbursement_cards#show
#                                                         DELETE /cards/reimbursement/orders/:id(.:format)                                       benefits/reimbursement_cards#destroy
#                            bank_transfer_reimbursements GET    /bank_transfer/reimbursements(.:format)                                         bank_transfer/reimbursement#show
#                                                         PATCH  /bank_transfer/reimbursements(.:format)                                         bank_transfer/reimbursement#update
#                                                         POST   /bank_transfer/reimbursements(.:format)                                         bank_transfer/reimbursement#create
#                                           kyc_docs_show GET    /kyc/company(.:format)                                                          kyc/companies#show
#                                         kyc_docs_update PATCH  /kyc/company(.:format)                                                          kyc/companies#update
#                                             kyc_confirm PATCH  /kyc/confirm(.:format)                                                          kyc/companies#confirm
#                                             kyc_retract PATCH  /kyc/retract(.:format)                                                          kyc/companies#retract
#                                                     kyc GET    /kyc/users/:id(.:format)                                                        kyc/user#show
#                                                         PATCH  /kyc/users/:id(.:format)                                                        kyc/user#update
#                                          disburse_users POST   /disburse/users(.:format)                                                       disburse/users#create
#                                     features_subscribed GET    /features_subscribed(.:format)                                                  expense_types_configuration#features_subscribed
#                                                  groups GET    /groups(.:format)                                                               user_groups#index
#                                                         POST   /groups(.:format)                                                               user_groups#create
#                                                   group PATCH  /groups/:id(.:format)                                                           user_groups#update
#                                                         PUT    /groups/:id(.:format)                                                           user_groups#update
#                                                         DELETE /groups/:id(.:format)                                                           user_groups#destroy
#                                             group_items POST   /groups/:group_id/items(.:format)                                               user_group_items#create
#                                              group_item GET    /groups/:group_id/items/:id(.:format)                                           user_group_items#show
#                                                         PATCH  /groups/:group_id/items/:id(.:format)                                           user_group_items#update
#                                                         PUT    /groups/:group_id/items/:id(.:format)                                           user_group_items#update
#                                                         DELETE /groups/:group_id/items/:id(.:format)                                           user_group_items#destroy
#                                                         POST   /groups/:group_id/items/:item_id(.:format)                                      user_group_items#create
#                                group_item_pending_users GET    /groups/:group_id/items/:item_id/pending_users(.:format)                        user_group_items#pending_users
#                                                         GET    /groups/:group_id/items(.:format)                                               items#index
#                                                         POST   /groups/:group_id/items(.:format)                                               items#create
#                                          new_group_item GET    /groups/:group_id/items/new(.:format)                                           items#new
#                                         edit_group_item GET    /groups/:group_id/items/:id/edit(.:format)                                      items#edit
#                                                         GET    /groups/:group_id/items/:id(.:format)                                           items#show
#                                                         PATCH  /groups/:group_id/items/:id(.:format)                                           items#update
#                                                         PUT    /groups/:group_id/items/:id(.:format)                                           items#update
#                                                         DELETE /groups/:group_id/items/:id(.:format)                                           items#destroy
#                                                         GET    /groups(.:format)                                                               groups#index
#                                                         POST   /groups(.:format)                                                               groups#create
#                                               new_group GET    /groups/new(.:format)                                                           groups#new
#                                              edit_group GET    /groups/:id/edit(.:format)                                                      groups#edit
#                                                         GET    /groups/:id(.:format)                                                           groups#show
#                                                         PATCH  /groups/:id(.:format)                                                           groups#update
#                                                         PUT    /groups/:id(.:format)                                                           groups#update
#                                                         DELETE /groups/:id(.:format)                                                           groups#destroy
#                                                   teams GET    /teams(.:format)                                                                user_teams#index
#                                                         POST   /teams(.:format)                                                                user_teams#create
#                                                    team GET    /teams/:id(.:format)                                                            user_teams#show
#                                                         PATCH  /teams/:id(.:format)                                                            user_teams#update
#                                                         PUT    /teams/:id(.:format)                                                            user_teams#update
#                                                         DELETE /teams/:id(.:format)                                                            user_teams#destroy
#                                   team_set_restrictions PATCH  /teams/:team_id/set_restrictions(.:format)                                      user_teams#set_restrictions
#                                                         GET    /teams(.:format)                                                                user_teams#index
#                                                         POST   /teams(.:format)                                                                user_teams#create
#                                                new_team GET    /teams/new(.:format)                                                            user_teams#new
#                                               edit_team GET    /teams/:id/edit(.:format)                                                       user_teams#edit
#                                                         GET    /teams/:id(.:format)                                                            user_teams#show
#                                                         PATCH  /teams/:id(.:format)                                                            user_teams#update
#                                                         PUT    /teams/:id(.:format)                                                            user_teams#update
#                                                         DELETE /teams/:id(.:format)                                                            user_teams#destroy
#                               authorizer_report_approve PATCH  /authorizer/reports/:report_id/approve(.:format)                                authorizer/reports#approve
#                                authorizer_report_reject PATCH  /authorizer/reports/:report_id/reject(.:format)                                 authorizer/reports#reject
#                                      authorizer_reports GET    /authorizer/reports(.:format)                                                   authorizer/reports#index
#                                                         POST   /authorizer/reports(.:format)                                                   authorizer/reports#create
#                                   new_authorizer_report GET    /authorizer/reports/new(.:format)                                               authorizer/reports#new
#                                  edit_authorizer_report GET    /authorizer/reports/:id/edit(.:format)                                          authorizer/reports#edit
#                                       authorizer_report GET    /authorizer/reports/:id(.:format)                                               authorizer/reports#show
#                                                         PATCH  /authorizer/reports/:id(.:format)                                               authorizer/reports#update
#                                                         PUT    /authorizer/reports/:id(.:format)                                               authorizer/reports#update
#                                                         DELETE /authorizer/reports/:id(.:format)                                               authorizer/reports#destroy
#                                          export_expense GET    /export/expense(.:format)                                                       export#expense
#                                  export_atm_transaction GET    /export/atm_transaction(.:format)                                               export#atm_transactions
#                                              agreements GET    /agreements(.:format)                                                           agreements#index
#                                     agreements_validate GET    /agreements/validate(.:format)                                                  agreements#validate
#                                        agreements_agree POST   /agreements/agree(.:format)                                                     agreements#agree
#                                      agreements_company GET    /agreements/company(.:format)                                                   agreements#company_data
#                                       agreements_update PATCH  /agreements/update(.:format)                                                    agreements#update
#                                                         GET    /auth/:provider/callback(.:format)                                              third_party_auth#quickbooks
#                                      testing_quickbooks GET    /testing_quickbooks(.:format)                                                   third_party_auth#testing
#                                  quickbooks_sync_report POST   /quickbooks/sync_report(.:format)                                               quickbooks#sync_report
#                                 quickbooks_sync_reports POST   /quickbooks/sync_reports(.:format)                                              quickbooks#sync_reports
#                              quickbooks_sync_categories POST   /quickbooks/sync_categories(.:format)                                           quickbooks#sync_categories
#                           quickbooks_sync_payment_types POST   /quickbooks/sync_payment_types(.:format)                                        quickbooks#sync_payment_types
#                                quickbooks_update_config PATCH  /quickbooks/update_config(.:format)                                             quickbooks#update
#                                       quickbooks_config GET    /quickbooks/config(.:format)                                                    quickbooks#show
#                                                     tos GET    /tos(.:format)                                                                  static_pages#tos
#                                                 privacy GET    /privacy(.:format)                                                              static_pages#privacy
#                                  prepaid_card_agreement GET    /prepaid_card_agreement(.:format)                                               static_pages#prepaid_card_agreement
#                            company_add_balance_payments POST   /payments/companies/:company_id/add_balance(.:format)                           companies#add_balance
#                                                         GET    /payments/companies(.:format)                                                   companies#index
#                                                         POST   /payments/companies(.:format)                                                   companies#create
#                                                         GET    /payments/companies/new(.:format)                                               companies#new
#                                                         GET    /payments/companies/:id/edit(.:format)                                          companies#edit
#                                                         GET    /payments/companies/:id(.:format)                                               companies#show
#                                                         PATCH  /payments/companies/:id(.:format)                                               companies#update
#                                                         PUT    /payments/companies/:id(.:format)                                               companies#update
#                                                         DELETE /payments/companies/:id(.:format)                                               companies#destroy
#               bank_transfer_payment_orders_process_file POST   /bank_transfer/payment_orders/process_file(.:format)                            bank_transfer/payment_orders#process_file
#                    bank_transfer_payment_orders_balance GET    /bank_transfer/payment_orders/balance(.:format)                                 bank_transfer/payment_orders#balance
#            bank_transfer_payment_orders_account_details POST   /bank_transfer/payment_orders/account_details(.:format)                         bank_transfer/payment_orders#account_details
#        bank_transfer_payment_orders_process_account_ids POST   /bank_transfer/payment_orders/process_account_ids(.:format)                     bank_transfer/payment_orders#process_account_ids
#                            bank_transfer_payment_orders GET    /bank_transfer/payment_orders(.:format)                                         bank_transfer/payment_orders#index
#                                                         POST   /bank_transfer/payment_orders(.:format)                                         bank_transfer/payment_orders#create
#                         new_bank_transfer_payment_order GET    /bank_transfer/payment_orders/new(.:format)                                     bank_transfer/payment_orders#new
#                        edit_bank_transfer_payment_order GET    /bank_transfer/payment_orders/:id/edit(.:format)                                bank_transfer/payment_orders#edit
#                             bank_transfer_payment_order GET    /bank_transfer/payment_orders/:id(.:format)                                     bank_transfer/payment_orders#show
#                                                         PATCH  /bank_transfer/payment_orders/:id(.:format)                                     bank_transfer/payment_orders#update
#                                                         PUT    /bank_transfer/payment_orders/:id(.:format)                                     bank_transfer/payment_orders#update
#                                                         DELETE /bank_transfer/payment_orders/:id(.:format)                                     bank_transfer/payment_orders#destroy
#                                   bank_transfer_vendors GET    /bank_transfer/vendors(.:format)                                                bank_transfer/vendors#index
#                                                         POST   /bank_transfer/vendors(.:format)                                                bank_transfer/vendors#create
#                                new_bank_transfer_vendor GET    /bank_transfer/vendors/new(.:format)                                            bank_transfer/vendors#new
#                               edit_bank_transfer_vendor GET    /bank_transfer/vendors/:id/edit(.:format)                                       bank_transfer/vendors#edit
#                                    bank_transfer_vendor GET    /bank_transfer/vendors/:id(.:format)                                            bank_transfer/vendors#show
#                                                         PATCH  /bank_transfer/vendors/:id(.:format)                                            bank_transfer/vendors#update
#                                                         PUT    /bank_transfer/vendors/:id(.:format)                                            bank_transfer/vendors#update
#                                                         DELETE /bank_transfer/vendors/:id(.:format)                                            bank_transfer/vendors#destroy
#                             bank_transfer_bank_accounts GET    /bank_transfer/bank_accounts(.:format)                                          bank_transfer/bank_accounts#index
#                                                         POST   /bank_transfer/bank_accounts(.:format)                                          bank_transfer/bank_accounts#create
#                          new_bank_transfer_bank_account GET    /bank_transfer/bank_accounts/new(.:format)                                      bank_transfer/bank_accounts#new
#                         edit_bank_transfer_bank_account GET    /bank_transfer/bank_accounts/:id/edit(.:format)                                 bank_transfer/bank_accounts#edit
#                              bank_transfer_bank_account GET    /bank_transfer/bank_accounts/:id(.:format)                                      bank_transfer/bank_accounts#show
#                                                         PATCH  /bank_transfer/bank_accounts/:id(.:format)                                      bank_transfer/bank_accounts#update
#                                                         PUT    /bank_transfer/bank_accounts/:id(.:format)                                      bank_transfer/bank_accounts#update
#                                                         DELETE /bank_transfer/bank_accounts/:id(.:format)                                      bank_transfer/bank_accounts#destroy
#                  admin_users_funds_load_request_approve PATCH  /admin/admin_users/funds_load_requests/:funds_load_request_id/approve(.:format) admin_users/funds_load_requests#approve
#                         admin_users_funds_load_requests GET    /admin/admin_users/funds_load_requests(.:format)                                admin_users/funds_load_requests#index
#                                                         POST   /admin/admin_users/funds_load_requests(.:format)                                admin_users/funds_load_requests#create
#                      new_admin_users_funds_load_request GET    /admin/admin_users/funds_load_requests/new(.:format)                            admin_users/funds_load_requests#new
#                     edit_admin_users_funds_load_request GET    /admin/admin_users/funds_load_requests/:id/edit(.:format)                       admin_users/funds_load_requests#edit
#                          admin_users_funds_load_request GET    /admin/admin_users/funds_load_requests/:id(.:format)                            admin_users/funds_load_requests#show
#                                                         PATCH  /admin/admin_users/funds_load_requests/:id(.:format)                            admin_users/funds_load_requests#update
#                                                         PUT    /admin/admin_users/funds_load_requests/:id(.:format)                            admin_users/funds_load_requests#update
#                                                         DELETE /admin/admin_users/funds_load_requests/:id(.:format)                            admin_users/funds_load_requests#destroy
#

#                               crono_web        /crono                                                      Crono::Web
# transcriber_transcribed_expenses_create POST   /transcriber/expenses/create(.:format)                      transcriber/receipts#create_expense
# transcriber_transcribed_expenses_update PATCH  /transcriber/expenses/:id/update(.:format)                  transcriber/receipts#update_expense
#    transcriber_transcribed_receipt_show GET    /transcriber/expenses/:id/show(.:format)                    transcriber/receipts#show
#      transcriber_untranscribed_receipts GET    /transcriber/companies/:id(.:format)                        transcriber/companies#show
#                   transcriber_companies GET    /transcriber/companies(.:format)                            transcriber/companies#index
#                               menu_data GET    /menu_data(.:format)                                        users#menu_data
#                  new_admin_user_session GET    /admin_users/sign_in(.:format)                              admin_users/sessions#new
#                      admin_user_session POST   /admin_users/sign_in(.:format)                              admin_users/sessions#create
#              destroy_admin_user_session DELETE /admin_users/sign_out(.:format)                             admin_users/sessions#destroy
#                     admin_user_password POST   /admin_users/password(.:format)                             devise/passwords#create
#                 new_admin_user_password GET    /admin_users/password/new(.:format)                         devise/passwords#new
#                edit_admin_user_password GET    /admin_users/password/edit(.:format)                        devise/passwords#edit
#                                         PATCH  /admin_users/password(.:format)                             devise/passwords#update
#                                         PUT    /admin_users/password(.:format)                             devise/passwords#update
#     api_v1_configuration_category_index GET    /api/v1/configuration/category/index(.:format)              api/v1/configuration/category#index
#           api_v1_configuration_category GET    /api/v1/configuration/category(.:format)                    api/v1/configuration#category
#                                         GET    /auth/:provider/callback(.:format)                          third_party_auth#quickbooks
#                      testing_quickbooks GET    /testing_quickbooks(.:format)                               third_party_auth#testing
#                         email_processor POST   /email/incoming(.:format)                                   griddler/emails#create
#                               oauth_new GET    /oauth/new(.:format)                                        oauth/auth#new
#                         oauth_authorize POST   /oauth/authorize(.:format)                                  opro/oauth/auth#create
#                             oauth_token POST   /oauth/token(.:format)                                      oauth/token#create {:format=>"json"}
#                       oauth_client_apps GET    /oauth_client_apps(.:format)                                opro/oauth/client_app#index
#                                         POST   /oauth_client_apps(.:format)                                opro/oauth/client_app#create
#                    new_oauth_client_app GET    /oauth_client_apps/new(.:format)                            opro/oauth/client_app#new
#                   edit_oauth_client_app GET    /oauth_client_apps/:id/edit(.:format)                       opro/oauth/client_app#edit
#                        oauth_client_app GET    /oauth_client_apps/:id(.:format)                            opro/oauth/client_app#show
#                                         PATCH  /oauth_client_apps/:id(.:format)                            opro/oauth/client_app#update
#                                         PUT    /oauth_client_apps/:id(.:format)                            opro/oauth/client_app#update
#                                         DELETE /oauth_client_apps/:id(.:format)                            opro/oauth/client_app#destroy
#                              oauth_docs GET    /oauth_docs(.:format)                                       opro/oauth/docs#index
#                               oauth_doc GET    /oauth_docs/:id(.:format)                                   opro/oauth/docs#show
#                             oauth_tests GET    /oauth_tests(.:format)                                      opro/oauth/tests#index
#                                         POST   /oauth_tests(.:format)                                      opro/oauth/tests#create
#                              oauth_test GET    /oauth_tests/:id(.:format)                                  opro/oauth/tests#show
#                                         DELETE /oauth_tests/:id(.:format)                                  opro/oauth/tests#destroy
#              admin_oauth_token_generate POST   /admin/oauth/token(.:format)                                admin_users/oauth/token#create {:format=>"json"}
#                           accept_invite GET    /users/invitation/accept(.:format)                          pending_invites#edit
#                    preview_registration POST   /welcome/preview(.:format)                                  registrations#preview
#                       resources_details POST   /resources_details(.:format)                                registrations#resource_requests
#                      resources_download GET    /download_resource(.:format)                                registrations#resources_download
#                        new_user_session GET    /users/sign_in(.:format)                                    sessions#new
#                            user_session POST   /users/sign_in(.:format)                                    sessions#create
#                    destroy_user_session DELETE /users/sign_out(.:format)                                   sessions#destroy
#                           user_password POST   /users/password(.:format)                                   passwords#create
#                       new_user_password GET    /users/password/new(.:format)                               passwords#new
#                      edit_user_password GET    /users/password/edit(.:format)                              passwords#edit
#                                         PATCH  /users/password(.:format)                                   passwords#update
#                                         PUT    /users/password(.:format)                                   passwords#update
#                cancel_user_registration GET    /users/cancel(.:format)                                     devise_invitable/registrations#cancel
#                       user_registration POST   /users(.:format)                                            devise_invitable/registrations#create
#                   new_user_registration GET    /users/sign_up(.:format)                                    devise_invitable/registrations#new
#                  edit_user_registration GET    /users/edit(.:format)                                       devise_invitable/registrations#edit
#                                         PATCH  /users(.:format)                                            devise_invitable/registrations#update
#                                         PUT    /users(.:format)                                            devise_invitable/registrations#update
#                                         DELETE /users(.:format)                                            devise_invitable/registrations#destroy
#                       user_confirmation POST   /users/confirmation(.:format)                               devise/confirmations#create
#                   new_user_confirmation GET    /users/confirmation/new(.:format)                           devise/confirmations#new
#                                         GET    /users/confirmation(.:format)                               devise/confirmations#show
#                             user_unlock POST   /users/unlock(.:format)                                     devise/unlocks#create
#                         new_user_unlock GET    /users/unlock/new(.:format)                                 devise/unlocks#new
#                                         GET    /users/unlock(.:format)                                     devise/unlocks#show
#                  accept_user_invitation GET    /users/invitation/accept(.:format)                          devise/invitations#edit
#                  remove_user_invitation GET    /users/invitation/remove(.:format)                          devise/invitations#destroy
#                         user_invitation POST   /users/invitation(.:format)                                 devise/invitations#create
#                     new_user_invitation GET    /users/invitation/new(.:format)                             devise/invitations#new
#                                         PATCH  /users/invitation(.:format)                                 devise/invitations#update
#                                         PUT    /users/invitation(.:format)                                 devise/invitations#update
#                         api_v0_expenses GET    /api/v0/expenses(.:format)                                  api/v0/expenses#index
#                                         POST   /api/v0/expenses(.:format)                                  api/v0/expenses#create
#                          api_v0_expense GET    /api/v0/expenses/:id(.:format)                              api/v0/expenses#show
#                                         PATCH  /api/v0/expenses/:id(.:format)                              api/v0/expenses#update
#                                         PUT    /api/v0/expenses/:id(.:format)                              api/v0/expenses#update
#                                         DELETE /api/v0/expenses/:id(.:format)                              api/v0/expenses#destroy
#                          api_v0_reports GET    /api/v0/reports(.:format)                                   api/v0/reports#index
#                                         POST   /api/v0/reports(.:format)                                   api/v0/reports#create
#                           api_v0_report GET    /api/v0/reports/:id(.:format)                               api/v0/reports#show
#                                         PATCH  /api/v0/reports/:id(.:format)                               api/v0/reports#update
#                                         PUT    /api/v0/reports/:id(.:format)                               api/v0/reports#update
#                                         DELETE /api/v0/reports/:id(.:format)                               api/v0/reports#destroy
#                   api_v0_report_comment POST   /api/v0/reports/:report_id/comment(.:format)                api/v0/reports#comment
#                   api_v0_report_retract PATCH  /api/v0/reports/:report_id/retract(.:format)                api/v0/reports#retract
#                    api_v0_report_submit PATCH  /api/v0/reports/:report_id/submit(.:format)                 api/v0/reports#submit
#                   api_v0_report_approve PATCH  /api/v0/reports/:report_id/approve(.:format)                api/v0/reports#approve
#                 api_v0_report_unapprove PATCH  /api/v0/reports/:report_id/unapprove(.:format)              api/v0/reports#unapprove
#                    api_v0_report_reject PATCH  /api/v0/reports/:report_id/reject(.:format)                 api/v0/reports#reject
#        api_v0_report_settlement_confirm PATCH  /api/v0/reports/:report_id/settlement_confirm(.:format)     api/v0/reports#settlement_confirm
#              api_v0_report_take_control PATCH  /api/v0/reports/:report_id/take_control(.:format)           api/v0/reports#take_control
#              api_v0_report_add_expenses POST   /api/v0/reports/:report_id/add_expenses(.:format)           api/v0/reports#add_expenses
#           api_v0_report_remove_expenses DELETE /api/v0/reports/:report_id/remove_expenses(.:format)        api/v0/reports#remove_expenses
#            api_v0_report_reject_expense PATCH  /api/v0/reports/:report_id/reject_expense(.:format)         api/v0/reports#reject_expense
#             api_v0_report_assign_policy POST   /api/v0/reports/:report_id/assign_policy(.:format)          api/v0/reports#assign_policy
#                                         GET    /api/v0/reports(.:format)                                   api/v0/reports#index
#                                         POST   /api/v0/reports(.:format)                                   api/v0/reports#create
#                       new_api_v0_report GET    /api/v0/reports/new(.:format)                               api/v0/reports#new
#                      edit_api_v0_report GET    /api/v0/reports/:id/edit(.:format)                          api/v0/reports#edit
#                                         GET    /api/v0/reports/:id(.:format)                               api/v0/reports#show
#                                         PATCH  /api/v0/reports/:id(.:format)                               api/v0/reports#update
#                                         PUT    /api/v0/reports/:id(.:format)                               api/v0/reports#update
#                                         DELETE /api/v0/reports/:id(.:format)                               api/v0/reports#destroy
#                         api_v0_receipts GET    /api/v0/receipts(.:format)                                  api/v0/receipts#index
#                                         POST   /api/v0/receipts(.:format)                                  api/v0/receipts#create
#                          api_v0_receipt PATCH  /api/v0/receipts/:id(.:format)                              api/v0/receipts#update
#                                         PUT    /api/v0/receipts/:id(.:format)                              api/v0/receipts#update
#                                         DELETE /api/v0/receipts/:id(.:format)                              api/v0/receipts#destroy
#     api_v0_receipt_expense_from_receipt POST   /api/v0/receipts/:receipt_id/expense_from_receipt(.:format) api/v0/receipts#expense_from_receipt
#                                         GET    /api/v0/receipts(.:format)                                  api/v0/receipts#index
#                                         POST   /api/v0/receipts(.:format)                                  api/v0/receipts#create
#                      new_api_v0_receipt GET    /api/v0/receipts/new(.:format)                              api/v0/receipts#new
#                     edit_api_v0_receipt GET    /api/v0/receipts/:id/edit(.:format)                         api/v0/receipts#edit
#                                         GET    /api/v0/receipts/:id(.:format)                              api/v0/receipts#show
#                                         PATCH  /api/v0/receipts/:id(.:format)                              api/v0/receipts#update
#                                         PUT    /api/v0/receipts/:id(.:format)                              api/v0/receipts#update
#                                         DELETE /api/v0/receipts/:id(.:format)                              api/v0/receipts#destroy
#         api_v0_configuration_categories GET    /api/v0/configuration/categories(.:format)                  api/v0/configuration/category#index
#       api_v0_configuration_gcm_register POST   /api/v0/configuration/gcm/register(.:format)                api/v0/configuration/gcm#create
#     api_v0_configuration_gcm_unregister POST   /api/v0/configuration/gcm/unregister(.:format)              api/v0/configuration/gcm#delete
#                         api_v1_expenses GET    /api/v1/expenses(.:format)                                  api/v1/expenses#index
#                                         POST   /api/v1/expenses(.:format)                                  api/v1/expenses#create
#                          api_v1_expense GET    /api/v1/expenses/:id(.:format)                              api/v1/expenses#show
#                                         PATCH  /api/v1/expenses/:id(.:format)                              api/v1/expenses#update
#                                         PUT    /api/v1/expenses/:id(.:format)                              api/v1/expenses#update
#                                         DELETE /api/v1/expenses/:id(.:format)                              api/v1/expenses#destroy
#                          api_v1_reports GET    /api/v1/reports(.:format)                                   api/v1/reports#index
#                                         POST   /api/v1/reports(.:format)                                   api/v1/reports#create
#                           api_v1_report GET    /api/v1/reports/:id(.:format)                               api/v1/reports#show
#                                         PATCH  /api/v1/reports/:id(.:format)                               api/v1/reports#update
#                                         PUT    /api/v1/reports/:id(.:format)                               api/v1/reports#update
#                                         DELETE /api/v1/reports/:id(.:format)                               api/v1/reports#destroy
#                   api_v1_report_comment POST   /api/v1/reports/:report_id/comment(.:format)                api/v1/reports#comment
#                                         GET    /api/v1/reports(.:format)                                   api/v1/reports#index
#                                         POST   /api/v1/reports(.:format)                                   api/v1/reports#create
#                       new_api_v1_report GET    /api/v1/reports/new(.:format)                               api/v1/reports#new
#                      edit_api_v1_report GET    /api/v1/reports/:id/edit(.:format)                          api/v1/reports#edit
#                                         GET    /api/v1/reports/:id(.:format)                               api/v1/reports#show
#                                         PATCH  /api/v1/reports/:id(.:format)                               api/v1/reports#update
#                                         PUT    /api/v1/reports/:id(.:format)                               api/v1/reports#update
#                                         DELETE /api/v1/reports/:id(.:format)                               api/v1/reports#destroy
#                   api_v1_money_requests GET    /api/v1/money_requests(.:format)                            api/v1/money_requests#index
#                                         POST   /api/v1/money_requests(.:format)                            api/v1/money_requests#create
#                    api_v1_money_request GET    /api/v1/money_requests/:id(.:format)                        api/v1/money_requests#show
#                                         PATCH  /api/v1/money_requests/:id(.:format)                        api/v1/money_requests#update
#                                         PUT    /api/v1/money_requests/:id(.:format)                        api/v1/money_requests#update
#                                         DELETE /api/v1/money_requests/:id(.:format)                        api/v1/money_requests#destroy
#            api_v1_money_request_comment POST   /api/v1/money_requests/:money_request_id/comment(.:format)  api/v1/money_requests#comment
#                                         GET    /api/v1/money_requests(.:format)                            api/v1/money_requests#index
#                                         POST   /api/v1/money_requests(.:format)                            api/v1/money_requests#create
#                new_api_v1_money_request GET    /api/v1/money_requests/new(.:format)                        api/v1/money_requests#new
#               edit_api_v1_money_request GET    /api/v1/money_requests/:id/edit(.:format)                   api/v1/money_requests#edit
#                                         GET    /api/v1/money_requests/:id(.:format)                        api/v1/money_requests#show
#                                         PATCH  /api/v1/money_requests/:id(.:format)                        api/v1/money_requests#update
#                                         PUT    /api/v1/money_requests/:id(.:format)                        api/v1/money_requests#update
#                                         DELETE /api/v1/money_requests/:id(.:format)                        api/v1/money_requests#destroy
#                         api_v1_receipts GET    /api/v1/receipts(.:format)                                  api/v1/receipts#index
#                                         POST   /api/v1/receipts(.:format)                                  api/v1/receipts#create
#                          api_v1_receipt PATCH  /api/v1/receipts/:id(.:format)                              api/v1/receipts#update
#                                         PUT    /api/v1/receipts/:id(.:format)                              api/v1/receipts#update
#                                         DELETE /api/v1/receipts/:id(.:format)                              api/v1/receipts#destroy
#                 api_v1_receipt_add_note POST   /api/v1/receipts/:receipt_id/add_note(.:format)             api/v1/receipts#add_note
#     api_v1_receipt_expense_from_receipt POST   /api/v1/receipts/:receipt_id/expense_from_receipt(.:format) api/v1/receipts#expense_from_receipt
#                                         GET    /api/v1/receipts(.:format)                                  api/v1/receipts#index
#                                         POST   /api/v1/receipts(.:format)                                  api/v1/receipts#create
#                      new_api_v1_receipt GET    /api/v1/receipts/new(.:format)                              api/v1/receipts#new
#                     edit_api_v1_receipt GET    /api/v1/receipts/:id/edit(.:format)                         api/v1/receipts#edit
#                                         GET    /api/v1/receipts/:id(.:format)                              api/v1/receipts#show
#                                         PATCH  /api/v1/receipts/:id(.:format)                              api/v1/receipts#update
#                                         PUT    /api/v1/receipts/:id(.:format)                              api/v1/receipts#update
#                                         DELETE /api/v1/receipts/:id(.:format)                              api/v1/receipts#destroy
#                            api_v1_users GET    /api/v1/users(.:format)                                     api/v1/users#index
#                             api_v1_user GET    /api/v1/users/:id(.:format)                                 api/v1/users#show
#                api_v1_user_user_summary GET    /api/v1/users/:user_id/summary(.:format)                    api/v1/users#summary
#                                         GET    /api/v1/users(.:format)                                     api/v1/users#index
#                                         POST   /api/v1/users(.:format)                                     api/v1/users#create
#                         new_api_v1_user GET    /api/v1/users/new(.:format)                                 api/v1/users#new
#                        edit_api_v1_user GET    /api/v1/users/:id/edit(.:format)                            api/v1/users#edit
#                                         GET    /api/v1/users/:id(.:format)                                 api/v1/users#show
#                                         PATCH  /api/v1/users/:id(.:format)                                 api/v1/users#update
#                                         PUT    /api/v1/users/:id(.:format)                                 api/v1/users#update
#                                         DELETE /api/v1/users/:id(.:format)                                 api/v1/users#destroy
#             api_v1_cards_balance_update POST   /api/v1/cards/balance/update(.:format)                      api/v1/cards#update_balance
#              api_v1_cards_status_update POST   /api/v1/cards/status/update(.:format)                       api/v1/cards#update_status
#         api_v1_configuration_categories GET    /api/v1/configuration/categories(.:format)                  api/v1/configuration/category#index
#       api_v1_configuration_gcm_register POST   /api/v1/configuration/gcm/register(.:format)                api/v1/configuration/gcm#create
#     api_v1_configuration_gcm_unregister POST   /api/v1/configuration/gcm/unregister(.:format)              api/v1/configuration/gcm#delete
#                         api_v1_balances GET    /api/v1/balances(.:format)                                  api/v1/users#balance
#          api_v1_available_expense_types GET    /api/v1/available_expense_types(.:format)                   api/v1/expenses#available_expense_types
#                  policies_expense_rules GET    /policies/expense_rules(.:format)                           policies#expense_rules
#                   policies_budget_rules GET    /policies/budget_rules(.:format)                            policies#budget_rules
#                 policies_policy_members GET    /policies/policy_members(.:format)                          policies#policy_members
#                    policies_create_rule GET    /policies/create_rule(.:format)                             policies#create_rule
#         policies_policy_member_settings GET    /policies/policy_member_settings(.:format)                  policies#policy_member_settings
#                        policies_details GET    /policies/details(.:format)                                 policies#details
#                       policies_personal GET    /policies/personal(.:format)                                policies#show_personal
#                                policies GET    /policies(.:format)                                         policies#index
#                                         POST   /policies(.:format)                                         policies#create
#                                  policy GET    /policies/:id(.:format)                                     policies#show
#                                         PATCH  /policies/:id(.:format)                                     policies#update
#                                         PUT    /policies/:id(.:format)                                     policies#update
#                                         DELETE /policies/:id(.:format)                                     policies#destroy
#                  policy_invitable_users POST   /policies/:policy_id/invitable_users(.:format)              policies#invitable_users
#                        policy_add_users POST   /policies/:policy_id/add_users(.:format)                    policies#add_users
#                     policy_remove_users POST   /policies/:policy_id/remove_users(.:format)                 policies#remove_users
#        policy_update_user_configuration PATCH  /policies/:policy_id/update_users_configuration(.:format)   policies#update_user_configuration
#                  policy_destroy_mapping DELETE /policies/:policy_id/remove_mapping/:mapping_id(.:format)   policies#destrot_mapping
#                         policy_add_rule POST   /policies/:policy_id/add_rule(.:format)                     rules#create
#                      policy_remove_rule DELETE /policies/:policy_id/remove_rule(.:format)                  rules#destroy
#                      policy_description GET    /policies/:policy_id/description(.:format)                  policies#show_description
#                                         GET    /policies(.:format)                                         policies#index
#                                         POST   /policies(.:format)                                         policies#create
#                              new_policy GET    /policies/new(.:format)                                     policies#new
#                             edit_policy GET    /policies/:id/edit(.:format)                                policies#edit
#                                         GET    /policies/:id(.:format)                                     policies#show
#                                         PATCH  /policies/:id(.:format)                                     policies#update
#                                         PUT    /policies/:id(.:format)                                     policies#update
#                                         DELETE /policies/:id(.:format)                                     policies#destroy
#                              categories GET    /categories(.:format)                                       categories#index
#                                         POST   /categories(.:format)                                       categories#create
#                            new_category GET    /categories/new(.:format)                                   categories#new
#                           edit_category GET    /categories/:id/edit(.:format)                              categories#edit
#                                category GET    /categories/:id(.:format)                                   categories#show
#                                         PATCH  /categories/:id(.:format)                                   categories#update
#                                         PUT    /categories/:id(.:format)                                   categories#update
#                                         DELETE /categories/:id(.:format)                                   categories#destroy
#                      export_preferences GET    /export_preferences(.:format)                               export_preferences#index
#                                         POST   /export_preferences(.:format)                               export_preferences#create
#                   new_export_preference GET    /export_preferences/new(.:format)                           export_preferences#new
#                  edit_export_preference GET    /export_preferences/:id/edit(.:format)                      export_preferences#edit
#                       export_preference GET    /export_preferences/:id(.:format)                           export_preferences#show
#                                         PATCH  /export_preferences/:id(.:format)                           export_preferences#update
#                                         PUT    /export_preferences/:id(.:format)                           export_preferences#update
#                                         DELETE /export_preferences/:id(.:format)                           export_preferences#destroy
#                       card_restrictions GET    /card_restrictions(.:format)                                card_restrictions#index
#                                         POST   /card_restrictions(.:format)                                card_restrictions#create
#                    new_card_restriction GET    /card_restrictions/new(.:format)                            card_restrictions#new
#                   edit_card_restriction GET    /card_restrictions/:id/edit(.:format)                       card_restrictions#edit
#                        card_restriction GET    /card_restrictions/:id(.:format)                            card_restrictions#show
#                                         PATCH  /card_restrictions/:id(.:format)                            card_restrictions#update
#                                         PUT    /card_restrictions/:id(.:format)                            card_restrictions#update
#                                         DELETE /card_restrictions/:id(.:format)                            card_restrictions#destroy
#                        companies_notify GET    /companies/notify(.:format)                                 companies#notify
#                     company_add_balance POST   /companies/:company_id/add_balance(.:format)                companies#add_balance
#                               companies GET    /companies(.:format)                                        companies#index
#                                         POST   /companies(.:format)                                        companies#create
#                             new_company GET    /companies/new(.:format)                                    companies#new
#                            edit_company GET    /companies/:id/edit(.:format)                               companies#edit
#                                 company GET    /companies/:id(.:format)                                    companies#show
#                                         PATCH  /companies/:id(.:format)                                    companies#update
#                                         PUT    /companies/:id(.:format)                                    companies#update
#                                         DELETE /companies/:id(.:format)                                    companies#destroy
#      organization_account_policies_list GET    /organization_account/policies_list(.:format)               organization_account#policies_list
#         organization_account_categories GET    /organization_account/categories(.:format)                  organization_account#categories
# organization_account_export_preferences GET    /organization_account/export_preferences(.:format)          organization_account#export_preferences
#                            add_category POST   /add_category(.:format)                                     organization_account#add_category
#                         remove_category DELETE /remove_category(.:format)                                  organization_account#remove_category
#                update_export_preference PATCH  /export/:id/update(.:format)                                organization_account#update_export_column
#                        add_export_field POST   /add_export_field(.:format)                                 organization_account#add_export_column
#                     delete_export_field DELETE /remove_export_field(.:format)                              organization_account#remove_export_column
#                                  people GET    /people(.:format)                                           people#people
#                           verify_mobile GET    /users/verify(.:format)                                     otp#edit
#                    update_mobile_number POST   /otp/update(.:format)                                       otp#update
#                              verify_otp POST   /otp/verify(.:format)                                       otp#verify
#                              resend_otp POST   /otp/resend(.:format)                                       otp#resend
#                            card_details POST   /cards/details(.:format)                                    cards#details
#                          update_balance POST   /cards/update_balance(.:format)                             cards#update_balance
#                      update_card_status POST   /cards/update_status(.:format)                              cards#update_status
#                                 reports GET    /reports(.:format)                                          reports#index
#                                         POST   /reports(.:format)                                          reports#create
#                                  report GET    /reports/:id(.:format)                                      reports#show
#                                         PATCH  /reports/:id(.:format)                                      reports#update
#                                         PUT    /reports/:id(.:format)                                      reports#update
#                                         DELETE /reports/:id(.:format)                                      reports#destroy
#                           export_report GET    /export/report(.:format)                                    export#report
#                          report_comment POST   /reports/:report_id/comment(.:format)                       reports#comment
#                          report_retract PATCH  /reports/:report_id/retract(.:format)                       reports#retract
#                           report_submit PATCH  /reports/:report_id/submit(.:format)                        reports#submit
#                          report_approve PATCH  /reports/:report_id/approve(.:format)                       reports#approve
#                        report_unapprove PATCH  /reports/:report_id/unapprove(.:format)                     reports#unapprove
#                           report_reject PATCH  /reports/:report_id/reject(.:format)                        reports#reject
#                   report_reject_expense PATCH  /reports/:report_id/reject_expense(.:format)                reports#reject_expense
#               report_settlement_confirm PATCH  /reports/:report_id/settlement_confirm(.:format)            reports#settlement_confirm
#                     report_take_control PATCH  /reports/:report_id/take_control(.:format)                  reports#take_control
#                     report_add_expenses POST   /reports/:report_id/add_expenses(.:format)                  reports#add_expenses
#                  report_remove_expenses DELETE /reports/:report_id/remove_expenses(.:format)               reports#remove_expenses
#          report_toggle_receipt_hardcopy POST   /reports/:report_id/toggle_receipt_hardcopy(.:format)       reports#toggle_receipt_hardcopy
#                                         GET    /reports(.:format)                                          reports#index
#                                         POST   /reports(.:format)                                          reports#create
#                              new_report GET    /reports/new(.:format)                                      reports#new
#                             edit_report GET    /reports/:id/edit(.:format)                                 reports#edit
#                                         GET    /reports/:id(.:format)                                      reports#show
#                                         PATCH  /reports/:id(.:format)                                      reports#update
#                                         PUT    /reports/:id(.:format)                                      reports#update
#                                         DELETE /reports/:id(.:format)                                      reports#destroy
#                     money_request_index GET    /money_request(.:format)                                    money_request#index
#                                         POST   /money_request(.:format)                                    money_request#create
#                           money_request GET    /money_request/:id(.:format)                                money_request#show
#                                         PATCH  /money_request/:id(.:format)                                money_request#update
#                                         PUT    /money_request/:id(.:format)                                money_request#update
#                                         DELETE /money_request/:id(.:format)                                money_request#destroy
#                   money_request_comment POST   /money_request/:money_request_id/comment(.:format)          money_request#comment
#                                         GET    /money_request(.:format)                                    money_request#index
#                                         POST   /money_request(.:format)                                    money_request#create
#                       new_money_request GET    /money_request/new(.:format)                                money_request#new
#                      edit_money_request GET    /money_request/:id/edit(.:format)                           money_request#edit
#                                         GET    /money_request/:id(.:format)                                money_request#show
#                                         PATCH  /money_request/:id(.:format)                                money_request#update
#                                         PUT    /money_request/:id(.:format)                                money_request#update
#                                         DELETE /money_request/:id(.:format)                                money_request#destroy
#                  expense_attach_receipt POST   /expenses/:expense_id/attach_receipt(.:format)              expenses#attach_receipt
#                  expense_detach_receipt POST   /expenses/:expense_id/detach_receipt(.:format)              expenses#detach_receipt
#                     expense_add_receipt POST   /expenses/:expense_id/add_receipt(.:format)                 expenses#add_receipt
#                            expense_mark PATCH  /expenses/:expense_id/mark(.:format)                        expenses#mark
#                          expense_unmark PATCH  /expenses/:expense_id/unmark(.:format)                      expenses#unmark
#                                expenses GET    /expenses(.:format)                                         expenses#index
#                                         POST   /expenses(.:format)                                         expenses#create
#                             new_expense GET    /expenses/new(.:format)                                     expenses#new
#                            edit_expense GET    /expenses/:id/edit(.:format)                                expenses#edit
#                                 expense GET    /expenses/:id(.:format)                                     expenses#show
#                                         PATCH  /expenses/:id(.:format)                                     expenses#update
#                                         PUT    /expenses/:id(.:format)                                     expenses#update
#                                         DELETE /expenses/:id(.:format)                                     expenses#destroy
#                     expenses_unreported POST   /expenses/unreported(.:format)                              expenses#unreported
#                        receipt_add_note POST   /receipts/:receipt_id/add_note(.:format)                    receipts#add_note
#            receipt_enable_transcription PATCH  /receipts/:receipt_id/enable(.:format)                      receipts#enable_transcription
#           receipt_disable_transcription PATCH  /receipts/:receipt_id/disable(.:format)                     receipts#disable_transcription
#                                receipts GET    /receipts(.:format)                                         receipts#index
#                                         POST   /receipts(.:format)                                         receipts#create
#                             new_receipt GET    /receipts/new(.:format)                                     receipts#new
#                            edit_receipt GET    /receipts/:id/edit(.:format)                                receipts#edit
#                                 receipt GET    /receipts/:id(.:format)                                     receipts#show
#                                         PATCH  /receipts/:id(.:format)                                     receipts#update
#                                         PUT    /receipts/:id(.:format)                                     receipts#update
#                                         DELETE /receipts/:id(.:format)                                     receipts#destroy
#                    expense_from_receipt POST   /expense_from_receipt(.:format)                             receipts#expense_from_receipt
#                      users_get_managers GET    /users/get_managers(.:format)                               users#get_managers
#                      users_user_profile GET    /users/user_profile(.:format)                               users#user_profile
#                      users_user_balance GET    /users/user_balance(.:format)                               users#user_balance
#                     users_user_security GET    /users/user_security(.:format)                              users#user_security
#                                  lookup GET    /lookup(.:format)                                           users#lookup
#                   send_verification_otp POST   /send_verification_otp(.:format)                            users#send_verification_otp
#                         verify_user_otp POST   /verify_user_otp(.:format)                                  users#verify_user_otp
#                            set_password POST   /set_password(.:format)                                     users#set_new_password
#                                   users GET    /users(.:format)                                            users#index
#                                         POST   /users(.:format)                                            users#create
#                                    user GET    /users/:id(.:format)                                        users#show
#                                         PATCH  /users/:id(.:format)                                        users#update
#                                         PUT    /users/:id(.:format)                                        users#update
#                                         DELETE /users/:id(.:format)                                        users#destroy
#                       user_user_summary GET    /users/:user_id/summary(.:format)                           users#summary
#                            user_details POST   /users/:user_id/user_details(.:format)                      users#user_details
#                        user_update_team PATCH  /users/:user_id/update_user_team(.:format)                  users#update_team
#                        user_update_role PATCH  /users/:user_id/update_role(.:format)                       users#update_user_role
#                            user_profile GET    /users/:user_id/profile(.:format)                           users#profile
#                    user_update_password POST   /users/:user_id/update_password(.:format)                   users#update_password
#                            user_balance GET    /users/:user_id/balance(.:format)                           users#balance
#          user_verify_reset_password_otp GET    /users/:user_id/verify_reset_otp(.:format)                  users#verify_reset_password_otp
#                                         GET    /users(.:format)                                            users#index
#                                         POST   /users(.:format)                                            users#create
#                                new_user GET    /users/new(.:format)                                        users#new
#                               edit_user GET    /users/:id/edit(.:format)                                   users#edit
#                                         GET    /users/:id(.:format)                                        users#show
#                                         PATCH  /users/:id(.:format)                                        users#update
#                                         PUT    /users/:id(.:format)                                        users#update
#                                         DELETE /users/:id(.:format)                                        users#destroy
#                 available_expense_types GET    /available_expense_types(.:format)                          users#available_expense_types
#                             user_import POST   /import(.:format)                                           users#import
#                       superadmin_import POST   /superadmin_import(.:format)                                admin/companies#import
#                     initiate_activation GET    /pending_invites/initiate_activation(.:format)              pending_invites#initiate_activation
#                       activate_employee GET    /pending_invites/activate_employee(.:format)                pending_invites#activate_employee
#                                send_otp GET    /pending_invites/send_otp(.:format)                         pending_invites#send_otp
#              manager_activation_sign_up PATCH  /pending_invites/manager_sign_up(.:format)                  pending_invites#manager_sign_up
#                 update_default_password POST   /users/update_default_password(.:format)                    users#update_default_password
#                   edit_default_password GET    /edit_default_password(.:format)                            users#edit_default_password
#                         pending_invites POST   /pending_invites(.:format)                                  pending_invites#create
#                     edit_pending_invite GET    /pending_invites/:id/edit(.:format)                         pending_invites#edit
#                          pending_invite PATCH  /pending_invites/:id(.:format)                              pending_invites#update
#                                         PUT    /pending_invites/:id(.:format)                              pending_invites#update
#                                         DELETE /pending_invites/:id(.:format)                              pending_invites#destroy
#                   pending_invite_accept PATCH  /pending_invites/:pending_invite_id/accept(.:format)        pending_invites#accept
#                                         GET    /pending_invites(.:format)                                  pending_invites#index
#                                         POST   /pending_invites(.:format)                                  pending_invites#create
#                      new_pending_invite GET    /pending_invites/new(.:format)                              pending_invites#new
#                                         GET    /pending_invites/:id/edit(.:format)                         pending_invites#edit
#                                         GET    /pending_invites/:id(.:format)                              pending_invites#show
#                                         PATCH  /pending_invites/:id(.:format)                              pending_invites#update
#                                         PUT    /pending_invites/:id(.:format)                              pending_invites#update
#                                         DELETE /pending_invites/:id(.:format)                              pending_invites#destroy
#                     settlements_summary GET    /settlements/summary(.:format)                              settlements#summary
#                             settlements GET    /settlements(.:format)                                      settlements#index
#                                         POST   /settlements(.:format)                                      settlements#create
#                          new_settlement GET    /settlements/new(.:format)                                  settlements#new
#                         edit_settlement GET    /settlements/:id/edit(.:format)                             settlements#edit
#                              settlement GET    /settlements/:id(.:format)                                  settlements#show
#                                         PATCH  /settlements/:id(.:format)                                  settlements#update
#                                         PUT    /settlements/:id(.:format)                                  settlements#update
#                                         DELETE /settlements/:id(.:format)                                  settlements#destroy
#                  settlement_add_payment POST   /settlements/:id/add_payment(.:format)                      settlements#add_payment
#                                         GET    /receipts(.:format)                                         receipts#index
#                                         POST   /receipts(.:format)                                         receipts#create
#                                         GET    /receipts/new(.:format)                                     receipts#new
#                                         GET    /receipts/:id/edit(.:format)                                receipts#edit
#                                         GET    /receipts/:id(.:format)                                     receipts#show
#                                         PATCH  /receipts/:id(.:format)                                     receipts#update
#                                         PUT    /receipts/:id(.:format)                                     receipts#update
#                                         DELETE /receipts/:id(.:format)                                     receipts#destroy
#         expense_type_configuration_show GET    /expense_type_configurations(.:format)                      expense_types_configuration#show
#       expense_type_configuration_update PATCH  /expense_type_configurations(.:format)                      expense_types_configuration#update
#                               per_diems GET    /per_diems(.:format)                                        per_diems#index
#                                         POST   /per_diems(.:format)                                        per_diems#create
#                            new_per_diem GET    /per_diems/new(.:format)                                    per_diems#new
#                           edit_per_diem GET    /per_diems/:id/edit(.:format)                               per_diems#edit
#                                per_diem GET    /per_diems/:id(.:format)                                    per_diems#show
#                                         PATCH  /per_diems/:id(.:format)                                    per_diems#update
#                                         PUT    /per_diems/:id(.:format)                                    per_diems#update
#                                         DELETE /per_diems/:id(.:format)                                    per_diems#destroy
#                   admin_users_companies GET    /admin_users/companies(.:format)                            admin_users/companies#index
#                                         POST   /admin_users/companies(.:format)                            admin_users/companies#create
#                 new_admin_users_company GET    /admin_users/companies/new(.:format)                        admin_users/companies#new
#                edit_admin_users_company GET    /admin_users/companies/:id/edit(.:format)                   admin_users/companies#edit
#                     admin_users_company GET    /admin_users/companies/:id(.:format)                        admin_users/companies#show
#                                         PATCH  /admin_users/companies/:id(.:format)                        admin_users/companies#update
#                                         PUT    /admin_users/companies/:id(.:format)                        admin_users/companies#update
#                                         DELETE /admin_users/companies/:id(.:format)                        admin_users/companies#destroy
#          admin_users_user_update_status PATCH  /admin_users/users/:user_id/update_status(.:format)         admin_users/users#update_status
#         admin_users_user_update_mapping PATCH  /admin_users/users/:user_id/update_mapping(.:format)        admin_users/users#update_mapping
#        admin_users_user_destroy_mapping DELETE /admin_users/users/:user_id/destroy_mapping(.:format)       admin_users/users#destroy_mapping
#                       admin_users_users GET    /admin_users/users(.:format)                                admin_users/users#index
#                                         POST   /admin_users/users(.:format)                                admin_users/users#create
#                    new_admin_users_user GET    /admin_users/users/new(.:format)                            admin_users/users#new
#                   edit_admin_users_user GET    /admin_users/users/:id/edit(.:format)                       admin_users/users#edit
#                        admin_users_user GET    /admin_users/users/:id(.:format)                            admin_users/users#show
#                                         PATCH  /admin_users/users/:id(.:format)                            admin_users/users#update
#                                         PUT    /admin_users/users/:id(.:format)                            admin_users/users#update
#                                         DELETE /admin_users/users/:id(.:format)                            admin_users/users#destroy
#                     admin_users_welcome POST   /admin_users/welcome(.:format)                              admin_users/users#admin_welcome
#                    admin_users_set_role POST   /admin_users/users/set_role(.:format)                       admin_users/users#set_role
#                      admin_users_lookup GET    /admin_users/lookup(.:format)                               admin_users/users#lookup
#                      admin_users_import POST   /admin_users/import(.:format)                               admin_users/users#import
#                 admin_users_temp_import GET    /admin_users/temp_import(.:format)                          admin_users/users#temp_import
#                    admin_users_expenses GET    /admin_users/expenses(.:format)                             admin_users/expenses#index
#                                         POST   /admin_users/expenses(.:format)                             admin_users/expenses#create
#                 new_admin_users_expense GET    /admin_users/expenses/new(.:format)                         admin_users/expenses#new
#                edit_admin_users_expense GET    /admin_users/expenses/:id/edit(.:format)                    admin_users/expenses#edit
#                     admin_users_expense GET    /admin_users/expenses/:id(.:format)                         admin_users/expenses#show
#                                         PATCH  /admin_users/expenses/:id(.:format)                         admin_users/expenses#update
#                                         PUT    /admin_users/expenses/:id(.:format)                         admin_users/expenses#update
#                                         DELETE /admin_users/expenses/:id(.:format)                         admin_users/expenses#destroy
#                  admin_users_card_block PATCH  /admin_users/cards/:card_id/block(.:format)                 admin_users/cards#block
#                       admin_users_cards GET    /admin_users/cards(.:format)                                admin_users/cards#index
#                                         POST   /admin_users/cards(.:format)                                admin_users/cards#create
#                    new_admin_users_card GET    /admin_users/cards/new(.:format)                            admin_users/cards#new
#                   edit_admin_users_card GET    /admin_users/cards/:id/edit(.:format)                       admin_users/cards#edit
#                        admin_users_card GET    /admin_users/cards/:id(.:format)                            admin_users/cards#show
#                                         PATCH  /admin_users/cards/:id(.:format)                            admin_users/cards#update
#                                         PUT    /admin_users/cards/:id(.:format)                            admin_users/cards#update
#                                         DELETE /admin_users/cards/:id(.:format)                            admin_users/cards#destroy
#                              admin_menu GET    /admin_menus(.:format)                                      admin_users/users#admin_menus
#                    transcriber_expenses GET    /transcriber/expenses(.:format)                             transcriber/expenses#index
#                                         POST   /transcriber/expenses(.:format)                             transcriber/expenses#create
#                 new_transcriber_expense GET    /transcriber/expenses/new(.:format)                         transcriber/expenses#new
#                edit_transcriber_expense GET    /transcriber/expenses/:id/edit(.:format)                    transcriber/expenses#edit
#                     transcriber_expense GET    /transcriber/expenses/:id(.:format)                         transcriber/expenses#show
#                                         PATCH  /transcriber/expenses/:id(.:format)                         transcriber/expenses#update
#                                         PUT    /transcriber/expenses/:id(.:format)                         transcriber/expenses#update
#                                         DELETE /transcriber/expenses/:id(.:format)                         transcriber/expenses#destroy
#                                         GET    /transcriber/companies(.:format)                            transcriber/companies#index
#                                         POST   /transcriber/companies(.:format)                            transcriber/companies#create
#                 new_transcriber_company GET    /transcriber/companies/new(.:format)                        transcriber/companies#new
#                edit_transcriber_company GET    /transcriber/companies/:id/edit(.:format)                   transcriber/companies#edit
#                     transcriber_company GET    /transcriber/companies/:id(.:format)                        transcriber/companies#show
#                                         PATCH  /transcriber/companies/:id(.:format)                        transcriber/companies#update
#                                         PUT    /transcriber/companies/:id(.:format)                        transcriber/companies#update
#                                         DELETE /transcriber/companies/:id(.:format)                        transcriber/companies#destroy
#                    transcriber_receipts GET    /transcriber/receipts(.:format)                             transcriber/receipts#index
#                                         POST   /transcriber/receipts(.:format)                             transcriber/receipts#create
#                 new_transcriber_receipt GET    /transcriber/receipts/new(.:format)                         transcriber/receipts#new
#                edit_transcriber_receipt GET    /transcriber/receipts/:id/edit(.:format)                    transcriber/receipts#edit
#                     transcriber_receipt GET    /transcriber/receipts/:id(.:format)                         transcriber/receipts#show
#                                         PATCH  /transcriber/receipts/:id(.:format)                         transcriber/receipts#update
#                                         PUT    /transcriber/receipts/:id(.:format)                         transcriber/receipts#update
#                                         DELETE /transcriber/receipts/:id(.:format)                         transcriber/receipts#destroy
#                       card_transactions GET    /card_transactions(.:format)                                card_transactions#index
#                                         POST   /card_transactions(.:format)                                card_transactions#create
#                    new_card_transaction GET    /card_transactions/new(.:format)                            card_transactions#new
#                   edit_card_transaction GET    /card_transactions/:id/edit(.:format)                       card_transactions#edit
#                        card_transaction GET    /card_transactions/:id(.:format)                            card_transactions#show
#                                         PATCH  /card_transactions/:id(.:format)                            card_transactions#update
#                                         PUT    /card_transactions/:id(.:format)                            card_transactions#update
#                                         DELETE /card_transactions/:id(.:format)                            card_transactions#destroy
#                  cancelled_transactions GET    /cancelled_against_transactions/:expense_id(.:format)       card_transactions#cancelled_transactions
#      statements_company_balance_summary GET    /statements/company_balance_summary(.:format)               statements#company_balance_summary
# statements_company_transactions_summary GET    /statements/company_transactions_summary(.:format)          statements#company_transactions_summary
#     statements_company_policies_summary GET    /statements/company_policies_summary(.:format)              statements#company_policies_summary
#                                         GET    /statements/:id/summary(.:format)                           statements#summary
#                        export_statement GET    /export/:id/statements(.:format)                            export#statement
#                              statements GET    /statements(.:format)                                       statements#index
#                                         POST   /statements(.:format)                                       statements#create
#                           new_statement GET    /statements/new(.:format)                                   statements#new
#                          edit_statement GET    /statements/:id/edit(.:format)                              statements#edit
#                               statement GET    /statements/:id(.:format)                                   statements#show
#                                         PATCH  /statements/:id(.:format)                                   statements#update
#                                         PUT    /statements/:id(.:format)                                   statements#update
#                                         DELETE /statements/:id(.:format)                                   statements#destroy
#                                    root GET    /                                                           home#index
#                                 welcome GET    /welcome(.:format)                                          home#welcome
#                                   about GET    /about(.:format)                                            home#about
#                               resources GET    /resources(.:format)                                        home#resources
#                   autocomplete_merchant GET    /autocomplete/merchant(.:format)                            autocomplete#merchant
#                       autocomplete_user GET    /autocomplete/user(.:format)                                autocomplete#user
#                     external_url_report GET    /external/reports/:id(.:format)                             external_url#report
#              external_url_money_request GET    /external/requests/:id(.:format)                            external_url#money_request
#                 external_url_settlement GET    /external/settlements/:id(.:format)                         external_url#payment
#                external_url_transaction GET    /external/transaction/:id(.:format)                         external_url#transaction
#                               analytics GET    /analytics(.:format)                                        analytics#show
#                                         GET    /companies/notify(.:format)                                 companies#notify
#                           notifications GET    /notifications(.:format)                                    notifications#index
#                    notifications_unread GET    /notifications/unread(.:format)                             notifications#unread
#             notifications_mark_all_read GET    /notifications/mark_all_read(.:format)                      notifications#mark_all_read
#                                    faqs GET    /faqs(.:format)                                             faqs#index
#                                feedback POST   /feedback(.:format)                                         feedback#create
#                         menu_data_cards GET    /menu_data_cards(.:format)                                  expense_types_configuration#menu_data_cards
#                      menu_data_disburse GET    /menu_data_disburse(.:format)                               expense_types_configuration#menu_data_disburse
#                            cards_orders GET    /cards/orders(.:format)                                     orders/order_cards#index
#                                         GET    /cards/orders/:id(.:format)                                 orders/order_cards#show
#                                         DELETE /cards/orders/:id(.:format)                                 orders/order_cards#destroy
#                 cards_meal_process_file POST   /cards/meal/process_file(.:format)                          benefits/meal_cards#process_file
#                       cards_meal_orders POST   /cards/meal/orders(.:format)                                benefits/meal_cards#create
#                                         PATCH  /cards/meal/orders(.:format)                                benefits/meal_cards#update
#                                         GET    /cards/meal/orders(.:format)                                benefits/meal_cards#index
#                                         GET    /cards/meal/orders/:id(.:format)                            benefits/meal_cards#show
#                                         DELETE /cards/meal/orders/:id(.:format)                            benefits/meal_cards#destroy
#              cards_medical_process_file POST   /cards/medical/process_file(.:format)                       benefits/medical_cards#process_file
#                    cards_medical_orders POST   /cards/medical/orders(.:format)                             benefits/medical_cards#create
#                                         PATCH  /cards/medical/orders(.:format)                             benefits/medical_cards#update
#                                         GET    /cards/medical/orders(.:format)                             benefits/medical_cards#index
#                                         GET    /cards/medical/orders/:id(.:format)                         benefits/medical_cards#show
#                                         DELETE /cards/medical/orders/:id(.:format)                         benefits/medical_cards#destroy
#              cards_expense_process_file POST   /cards/expense/process_file(.:format)                       benefits/expense_cards#process_file
#                    cards_expense_orders POST   /cards/expense/orders(.:format)                             benefits/expense_cards#create
#                                         PATCH  /cards/expense/orders(.:format)                             benefits/expense_cards#update
#                                         GET    /cards/expense/orders(.:format)                             benefits/expense_cards#index
#                                         GET    /cards/expense/orders/:id(.:format)                         benefits/expense_cards#show
#                                         DELETE /cards/expense/orders/:id(.:format)                         benefits/expense_cards#destroy
#        cards_reimbursement_process_file POST   /cards/reimbursement/process_file(.:format)                 benefits/reimbursement_cards#process_file
#              cards_reimbursement_orders POST   /cards/reimbursement/orders(.:format)                       benefits/reimbursement_cards#create
#                                         PATCH  /cards/reimbursement/orders(.:format)                       benefits/reimbursement_cards#update
#                                         GET    /cards/reimbursement/orders(.:format)                       benefits/reimbursement_cards#index
#                                         GET    /cards/reimbursement/orders/:id(.:format)                   benefits/reimbursement_cards#show
#                                         DELETE /cards/reimbursement/orders/:id(.:format)                   benefits/reimbursement_cards#destroy
#            bank_transfer_reimbursements GET    /bank_transfer/reimbursements(.:format)                     bank_transfer/reimbursement#show
#                                         PATCH  /bank_transfer/reimbursements(.:format)                     bank_transfer/reimbursement#update
#                                         POST   /bank_transfer/reimbursements(.:format)                     bank_transfer/reimbursement#create
#                          disburse_users POST   /disburse/users(.:format)                                   disburse/users#create
#                     features_subscribed GET    /features_subscribed(.:format)                              expense_types_configuration#features_subscribed
#                                  groups GET    /groups(.:format)                                           user_groups#index
#                                         POST   /groups(.:format)                                           user_groups#create
#                                   group PATCH  /groups/:id(.:format)                                       user_groups#update
#                                         PUT    /groups/:id(.:format)                                       user_groups#update
#                                         DELETE /groups/:id(.:format)                                       user_groups#destroy

#                                   teams GET    /teams(.:format)                                            user_teams#index
#                                         POST   /teams(.:format)                                            user_teams#create
#                                    team GET    /teams/:id(.:format)                                        user_teams#show
#                                         PATCH  /teams/:id(.:format)                                        user_teams#update
#                                         PUT    /teams/:id(.:format)                                        user_teams#update
#                                         DELETE /teams/:id(.:format)                                        user_teams#destroy
#                   team_set_restrictions PATCH  /teams/:team_id/set_restrictions(.:format)                  user_teams#set_restrictions
#                                         GET    /teams(.:format)                                            user_teams#index
#                                         POST   /teams(.:format)                                            user_teams#create
#                                new_team GET    /teams/new(.:format)                                        user_teams#new
#                               edit_team GET    /teams/:id/edit(.:format)                                   user_teams#edit
#                                         GET    /teams/:id(.:format)                                        user_teams#show
#                                         PATCH  /teams/:id(.:format)                                        user_teams#update
#                                         PUT    /teams/:id(.:format)                                        user_teams#update
#                                         DELETE /teams/:id(.:format)                                        user_teams#destroy
#

Rails.application.routes.draw do

  get 'qukickbooks_configurations/create'
  get 'qukickbooks_configurations/update'
  get 'qukickbooks_configurations/show'

  # adding this before the devise routes because devise overrides out custom path
  get '/users/invitation/accept', to: 'pending_invites#edit', as: :accept_invite


  ######### GEMS SPECIFIC START ###########

  mount Crono::Web, at: '/crono'
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
  # mount_opro_oauth controllers: {
  #     oauth_new: 'oauth/auth',
  #     oauth_token: 'oauth/token'
  # }
  #
  devise_for :users, controllers: {passwords: 'passwords', sessions: 'sessions'}
  use_doorkeeper do
    # it accepts :authorizations, :tokens, :applications and :authorized_applications
    controllers :tokens => 'oauth/token'
  end

  ######### GEMS SPECIFIC END ###########

  ######### MOBILE LEGACY START ###########

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

      get 'kyc/:id', to: 'kyc/user#show'
      post 'kyc/:id', to: 'kyc/user#update'
    end
  end

  ######### MOBILE LEGACY END ###########

  ######### MOBILE START ###########

  namespace :mobile do
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
      post 'auth', to: 'token#create'
      get 'configuration/category'
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
        get 'category/index'
        get 'categories' => 'category#index', as: :categories
        post 'gcm/register', to: 'gcm#create'
        post 'gcm/unregister', to: 'gcm#delete'
      end
      get 'balances', to: 'users#balance'
      get 'available_expense_types', to: 'expenses#available_expense_types'

      get 'kyc/:id', to: 'kyc/user#show'
      post 'kyc/:id', to: 'kyc/user#update'
      post 'kyc/:id/submit', to: 'kyc/user#submit'
      post 'kyc/:id/update_and_submit', to: 'kyc/user#update_and_submit'
      post 'kyc/:id/retract', to: 'kyc/user#retract'

      get 'transactions', to: 'cards#transactions'
      post 'lookup', to: 'users#lookup'
      post 'send_verification_otp', to: 'users#send_verification_otp'
      post 'verify_user_otp', to: 'users#verify_user_otp'
    end
  end

  ######### MOBILE END ###########

  ######### CHROME START ###########
  namespace :chrome do
    namespace :v1 do

      post 'auth', to: 'token#create'
      delete 'auth', to: 'token#destroy'

      post 'expenses/configuration', to: 'expenses#configuration'
      resources :expenses, only: [:create, :update, :destroy]
      post 'emails/:id', to: 'receipt_email#show'
    end
  end
  ######### CHROME END ###########

  ######### API START ###########
  namespace :api do
    namespace :fm do
      namespace :v1 do
        post 'auth', to: 'token#create'
        delete 'auth', to: 'token#destroy'
        resources :users, only: [:create, :show, :index, :update]
        resources :cards, only: [:index, :show]
        resources :cards do
          get 'transactions', to: 'cards#transactions'
          # patch 'assign', to: 'cards#assign'
          patch 'status', to: 'cards#update_status'
          # patch 'restrictions', to: 'cards#update_restrictions'
        end
        post 'funds/credit', to: 'funds#credit'
        post 'funds/debit', to: 'funds#debit'
        # post 'cards/request', to: 'cards#request'
      end
    end
  end
  ######### API END ###########

  ######### ADMIN PANEL START ###########

  namespace :transcriber do
    post 'expenses/create', to: 'receipts#create_expense', as: :transcribed_expenses_create
    patch 'expenses/:id/update', to: 'receipts#update_expense', as: :transcribed_expenses_update
    get 'expenses/:id/show', to: 'receipts#show', as: :transcribed_receipt_show
    get 'companies/:id', to: 'companies#show', as: :untranscribed_receipts
    get 'companies', to: 'companies#index', as: :companies
    resources :expenses
    resources :companies
    resources :receipts
  end

  namespace :admin_users do
    resources :companies do
      post 'dcode_check', to: 'companies#check_dcode'
      post 'configure_payu', to: 'companies#configure_payu'
    end
    get 'company_types', to: 'companies#company_types'
    resources :users do
      patch 'update_status', to: 'users#update_status', as: :update_status
      patch 'update_mapping', to: 'users#update_mapping', as: :update_mapping
      delete 'destroy_mapping', to: 'users#destroy_mapping', as: :destroy_mapping
      patch 'update_panel', to: 'users#update_panel', as: :update_panel
    end
    post 'welcome', to: 'users#admin_welcome', as: :welcome
    post 'users/set_role', to: 'users#set_role', as: :set_role
    get 'lookup', to: 'users#lookup', as: :lookup
    post 'import', to: 'users#import', as: :import
    get 'temp_import', to: 'users#temp_import'
    resources :expenses
    resources :cards do
      patch 'block', to: 'cards#block', as: :block
    end
    post 'import_cards', to: 'cards#import', as: :import_cards
    namespace :kyc do
      resources :companies do
        patch 'reject', to: 'companies#reject', as: :reject
        patch 'confirm', to: 'companies#confirm', as: :confirm
      end

      # Upgrade Card Workflow
      get 'users', to: 'users#index'
      get 'users/history', to: 'users#history_index'
      post 'users/approve', to: 'users#approve'
      post 'users/reject', to: 'users#reject'
      post 'users/mark_as_upgraded', to: 'users#mark_as_upgraded'
      patch 'users/:id', to: 'users#update'
      get 'users/export(.:format)' => 'users#export'
      get 'users/export/kycs(.:format)' => 'users#download_kycs'
    end
    resources :agreements, only: [:create, :index]

    namespace :verifier do
      get 'companies', to: 'company#index'
      get 'companies/history', to: 'company#history_index'
    end
    # Assign Card Workflow
    get 'card_assign_requests', to: 'card_assign_requests#index'
    get 'card_assign_requests/history', to: 'card_assign_requests#history_index'
    post 'card_assign_requests/approve', to: 'card_assign_requests#approve'
    post 'card_assign_requests/reject', to: 'card_assign_requests#reject'
    post 'card_assign_requests/mark_assigned', to: 'card_assign_requests#mark_as_assigned'
    post 'card_assign_requests/mark_assigned_upgraded', to: 'card_assign_requests#mark_as_assigned_upgraded'
    patch 'card_assign_requests/:id', to: 'card_assign_requests#update'
    get 'card_assign_requests/export(.:format)' => 'card_assign_requests#export'
    get 'card_assign_requests/export/kycs(.:format)' => 'card_assign_requests#download_kycs'
    get 'card_assign_requests/edit' => 'card_assign_requests#edit'

    post 'call_center/search', to: 'call_center/users#search', as: :search
  end

  get 'admin_menus', to: 'admin_users/users#admin_menus', as: :admin_menu

  ######### ADMIN PANEL END ###########

  get 'junk/show', to: 'junk#show'

  get 'menu_data', to: 'users#menu_data'

  # adding admin oauth token creation for admin login
  post 'admin/oauth/token', to: 'admin_users/oauth/token#create', as: :admin_oauth_token_generate, defaults: {format: 'json'}

  post '/welcome/preview', to: 'registrations#preview', as: :preview_registration
  post '/resources_details', to: 'registrations#resource_requests', as: :resources_details
  get 'download_resource', to: 'registrations#resources_download', as: :resources_download

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
  patch 'cards/assign', to: 'cards#assign', as: :assign_card
  patch 'cards/assign/:id/cancel', to: 'cards#cancel_assign', as: :cancel_assign_request
  get 'cards/unassigned', to: 'cards#unassigned', as: :unassigned_cards

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
    post 'toggle_receipt_hardcopy' => 'reports#toggle_receipt_hardcopy', as: :toggle_receipt_hardcopy
  end
  post 'reports/bulk_approve' => 'reports#bulk_approve', as: :reports_bulk_approve


  resources :money_request, only: [:create, :index, :show, :destroy, :update]
  resources :money_request do
    post 'comment' => 'money_request#comment', as: :comment
  end

  delete 'expenses', to: 'expenses#destroy'
  resources :expenses do
    post 'attach_receipt', to: 'expenses#attach_receipt'
    post 'detach_receipt', to: 'expenses#detach_receipt'
    post 'add_receipt', to: 'expenses#add_receipt'
    patch 'mark', to: 'expenses#mark', as: :mark
    patch 'unmark', to: 'expenses#unmark', as: :unmark
    get 'duplicates', to: 'expenses#duplicates'
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

  get 'expense_type_configurations', to: 'expense_types_configuration#show', as: :expense_type_configuration_show
  patch 'expense_type_configurations', to: 'expense_types_configuration#update', as: :expense_type_configuration_update

  resources :per_diems

  resources :card_transactions do

  end

  get 'atm_withdrawals', to: 'card_transactions#atm_withdrawals', as: :atm_withdrawals
  get 'refunds', to: 'card_transactions#refunds', as: :refunds

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
  get 'autocomplete/card', to: 'autocomplete#card'


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
  get 'menu_data_payments' => 'expense_types_configuration#menu_data_payments'

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

  namespace :kyc do
    get 'company', to: 'companies#show', as: :docs_show
    patch 'company', to: 'companies#update', as: :docs_update
    patch 'confirm', to: 'companies#confirm', as: :confirm
    patch 'retract', to: 'companies#retract', as: :retract

    get 'users/:id', to: 'user#show'
    patch 'users/:id', to: 'user#update'
  end

  # Disburse
  post 'disburse/users' => 'disburse/users#create'

  get 'features_subscribed' => 'expense_types_configuration#features_subscribed'
  resources :groups, controller: 'user_groups', only: [:create, :index, :update, :destroy]
  resources :groups do
    resources :items, controller: 'user_group_items', only: [:show, :create, :destroy, :update]
    resources :items do
      post '', to: 'user_group_items#create'
      get :pending_users, to: 'user_group_items#pending_users'
    end
  end

  resources :teams, controller: 'user_teams', only: [:create, :index, :show, :update, :destroy]
  resources :teams, controller: 'user_teams' do
    patch 'set_restrictions', to: 'user_teams#set_restrictions'
  end

  namespace :authorizer do
    resources :reports do
      patch 'approve' => 'reports#approve', as: :approve
      patch 'reject' => 'reports#reject', as: :reject
    end
  end

  get 'export/expense', to: 'export#expense'
  get 'export/atm_transaction', to: 'export#atm_transactions'

  get 'agreements', to: 'agreements#index'
  get 'agreements/validate', to: 'agreements#validate'
  post 'agreements/agree', to: 'agreements#agree'
  get 'agreements/company', to: 'agreements#company_data'
  patch 'agreements/update', to: 'agreements#update'

  # All APIs for Quickbooks integration and syncing

  get '/auth/:provider/callback', controller: 'third_party_auth', action: 'quickbooks'
  get 'testing_quickbooks', to: 'third_party_auth#testing'


  post 'quickbooks/sync_report', to: 'quickbooks#sync_report', as: :quickbooks_sync_report
  post 'quickbooks/sync_reports', to: 'quickbooks#sync_reports', as: :quickbooks_sync_reports
  post 'quickbooks/sync_categories', to: 'quickbooks#sync_categories', as: :quickbooks_sync_categories
  post 'quickbooks/sync_payment_types', to: 'quickbooks#sync_payment_types', as: :quickbooks_sync_payment_types
  patch 'quickbooks/update_config', to: 'quickbooks#update', as: :quickbooks_update_config
  get 'quickbooks/config', to: 'quickbooks#show', as: :quickbooks_config

  get 'tos', to: 'static_pages#tos'
  get 'privacy', to: 'static_pages#privacy'
  get 'prepaid_card_agreement', to: 'static_pages#prepaid_card_agreement'



  # ROUTES FOR VENDOR PAYMENTS
  scope :payments do
    resources :companies do
      post 'add_balance', to: 'companies#add_balance', as: :add_balance_payments
    end
  end
  namespace :bank_transfer do
    post 'payment_orders/process_file', to: 'payment_orders#process_file'
    get 'payment_orders/balance', to: 'payment_orders#balance'
    post 'payment_orders/account_details', to: 'payment_orders#account_details'
    post 'payment_orders/process_account_ids', to: 'payment_orders#process_account_ids'
    resources :payment_orders do

    end
    resources :vendors
    resources :bank_accounts
  end


  scope :admin do
    namespace :admin_users do
      resources :funds_load_requests do
        patch 'approve', to: 'funds_load_requests#approve'
      end
    end
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
