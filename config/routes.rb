# == Route Map
#
#                                   Prefix Verb       URI Pattern                                                 Controller#Action
#                   new_admin_user_session GET        /admin/login(.:format)                                      active_admin/devise/sessions#new
#                       admin_user_session POST       /admin/login(.:format)                                      active_admin/devise/sessions#create
#               destroy_admin_user_session DELETE|GET /admin/logout(.:format)                                     active_admin/devise/sessions#destroy
#                      admin_user_password POST       /admin/password(.:format)                                   active_admin/devise/passwords#create
#                  new_admin_user_password GET        /admin/password/new(.:format)                               active_admin/devise/passwords#new
#                 edit_admin_user_password GET        /admin/password/edit(.:format)                              active_admin/devise/passwords#edit
#                                          PATCH      /admin/password(.:format)                                   active_admin/devise/passwords#update
#                                          PUT        /admin/password(.:format)                                   active_admin/devise/passwords#update
#                               admin_root GET        /admin(.:format)                                            admin/dashboard#index
#           batch_action_admin_admin_users POST       /admin/admin_users/batch_action(.:format)                   admin/admin_users#batch_action
#                        admin_admin_users GET        /admin/admin_users(.:format)                                admin/admin_users#index
#                                          POST       /admin/admin_users(.:format)                                admin/admin_users#create
#                     new_admin_admin_user GET        /admin/admin_users/new(.:format)                            admin/admin_users#new
#                    edit_admin_admin_user GET        /admin/admin_users/:id/edit(.:format)                       admin/admin_users#edit
#                         admin_admin_user GET        /admin/admin_users/:id(.:format)                            admin/admin_users#show
#                                          PATCH      /admin/admin_users/:id(.:format)                            admin/admin_users#update
#                                          PUT        /admin/admin_users/:id(.:format)                            admin/admin_users#update
#                                          DELETE     /admin/admin_users/:id(.:format)                            admin/admin_users#destroy
#             batch_action_admin_companies POST       /admin/companies/batch_action(.:format)                     admin/companies#batch_action
#                          admin_companies GET        /admin/companies(.:format)                                  admin/companies#index
#                                          POST       /admin/companies(.:format)                                  admin/companies#create
#                        new_admin_company GET        /admin/companies/new(.:format)                              admin/companies#new
#                       edit_admin_company GET        /admin/companies/:id/edit(.:format)                         admin/companies#edit
#                            admin_company GET        /admin/companies/:id(.:format)                              admin/companies#show
#                                          PATCH      /admin/companies/:id(.:format)                              admin/companies#update
#                                          PUT        /admin/companies/:id(.:format)                              admin/companies#update
#                                          DELETE     /admin/companies/:id(.:format)                              admin/companies#destroy
#                          admin_dashboard GET        /admin/dashboard(.:format)                                  admin/dashboard#index
#              batch_action_admin_expenses POST       /admin/expenses/batch_action(.:format)                      admin/expenses#batch_action
#                           admin_expenses GET        /admin/expenses(.:format)                                   admin/expenses#index
#                                          POST       /admin/expenses(.:format)                                   admin/expenses#create
#                        new_admin_expense GET        /admin/expenses/new(.:format)                               admin/expenses#new
#                       edit_admin_expense GET        /admin/expenses/:id/edit(.:format)                          admin/expenses#edit
#                            admin_expense GET        /admin/expenses/:id(.:format)                               admin/expenses#show
#                                          PATCH      /admin/expenses/:id(.:format)                               admin/expenses#update
#                                          PUT        /admin/expenses/:id(.:format)                               admin/expenses#update
#                                          DELETE     /admin/expenses/:id(.:format)                               admin/expenses#destroy
#        batch_action_admin_money_requests POST       /admin/money_requests/batch_action(.:format)                admin/money_requests#batch_action
#                     admin_money_requests GET        /admin/money_requests(.:format)                             admin/money_requests#index
#                                          POST       /admin/money_requests(.:format)                             admin/money_requests#create
#                  new_admin_money_request GET        /admin/money_requests/new(.:format)                         admin/money_requests#new
#                 edit_admin_money_request GET        /admin/money_requests/:id/edit(.:format)                    admin/money_requests#edit
#                      admin_money_request GET        /admin/money_requests/:id(.:format)                         admin/money_requests#show
#                                          PATCH      /admin/money_requests/:id(.:format)                         admin/money_requests#update
#                                          PUT        /admin/money_requests/:id(.:format)                         admin/money_requests#update
#                                          DELETE     /admin/money_requests/:id(.:format)                         admin/money_requests#destroy
#              batch_action_admin_policies POST       /admin/policies/batch_action(.:format)                      admin/policies#batch_action
#                           admin_policies GET        /admin/policies(.:format)                                   admin/policies#index
#                                          POST       /admin/policies(.:format)                                   admin/policies#create
#                         new_admin_policy GET        /admin/policies/new(.:format)                               admin/policies#new
#                        edit_admin_policy GET        /admin/policies/:id/edit(.:format)                          admin/policies#edit
#                             admin_policy GET        /admin/policies/:id(.:format)                               admin/policies#show
#                                          PATCH      /admin/policies/:id(.:format)                               admin/policies#update
#                                          PUT        /admin/policies/:id(.:format)                               admin/policies#update
#                                          DELETE     /admin/policies/:id(.:format)                               admin/policies#destroy
# batch_action_admin_preview_registrations POST       /admin/preview_registrations/batch_action(.:format)         admin/preview_registrations#batch_action
#              admin_preview_registrations GET        /admin/preview_registrations(.:format)                      admin/preview_registrations#index
#                                          POST       /admin/preview_registrations(.:format)                      admin/preview_registrations#create
#           new_admin_preview_registration GET        /admin/preview_registrations/new(.:format)                  admin/preview_registrations#new
#          edit_admin_preview_registration GET        /admin/preview_registrations/:id/edit(.:format)             admin/preview_registrations#edit
#               admin_preview_registration GET        /admin/preview_registrations/:id(.:format)                  admin/preview_registrations#show
#                                          PATCH      /admin/preview_registrations/:id(.:format)                  admin/preview_registrations#update
#                                          PUT        /admin/preview_registrations/:id(.:format)                  admin/preview_registrations#update
#                                          DELETE     /admin/preview_registrations/:id(.:format)                  admin/preview_registrations#destroy
#               batch_action_admin_reports POST       /admin/reports/batch_action(.:format)                       admin/reports#batch_action
#                            admin_reports GET        /admin/reports(.:format)                                    admin/reports#index
#                                          POST       /admin/reports(.:format)                                    admin/reports#create
#                         new_admin_report GET        /admin/reports/new(.:format)                                admin/reports#new
#                        edit_admin_report GET        /admin/reports/:id/edit(.:format)                           admin/reports#edit
#                             admin_report GET        /admin/reports/:id(.:format)                                admin/reports#show
#                                          PATCH      /admin/reports/:id(.:format)                                admin/reports#update
#                                          PUT        /admin/reports/:id(.:format)                                admin/reports#update
#                                          DELETE     /admin/reports/:id(.:format)                                admin/reports#destroy
#                 batch_action_admin_users POST       /admin/users/batch_action(.:format)                         admin/users#batch_action
#                              admin_users GET        /admin/users(.:format)                                      admin/users#index
#                                          POST       /admin/users(.:format)                                      admin/users#create
#                           new_admin_user GET        /admin/users/new(.:format)                                  admin/users#new
#                          edit_admin_user GET        /admin/users/:id/edit(.:format)                             admin/users#edit
#                               admin_user GET        /admin/users/:id(.:format)                                  admin/users#show
#                                          PATCH      /admin/users/:id(.:format)                                  admin/users#update
#                                          PUT        /admin/users/:id(.:format)                                  admin/users#update
#                                          DELETE     /admin/users/:id(.:format)                                  admin/users#destroy
#                           admin_comments GET        /admin/comments(.:format)                                   admin/comments#index
#                                          POST       /admin/comments(.:format)                                   admin/comments#create
#                            admin_comment GET        /admin/comments/:id(.:format)                               admin/comments#show
#                                          DELETE     /admin/comments/:id(.:format)                               admin/comments#destroy
#      api_v1_configuration_category_index GET        /api/v1/configuration/category/index(.:format)              api/v1/configuration/category#index
#            api_v1_configuration_category GET        /api/v1/configuration/category(.:format)                    api/v1/configuration#category
#                          email_processor POST       /email/incoming(.:format)                                   griddler/emails#create
#                                oauth_new GET        /oauth/new(.:format)                                        oauth/auth#new
#                          oauth_authorize POST       /oauth/authorize(.:format)                                  opro/oauth/auth#create
#                              oauth_token POST       /oauth/token(.:format)                                      oauth/token#create {:format=>"json"}
#                        oauth_client_apps GET        /oauth_client_apps(.:format)                                opro/oauth/client_app#index
#                                          POST       /oauth_client_apps(.:format)                                opro/oauth/client_app#create
#                     new_oauth_client_app GET        /oauth_client_apps/new(.:format)                            opro/oauth/client_app#new
#                    edit_oauth_client_app GET        /oauth_client_apps/:id/edit(.:format)                       opro/oauth/client_app#edit
#                         oauth_client_app GET        /oauth_client_apps/:id(.:format)                            opro/oauth/client_app#show
#                                          PATCH      /oauth_client_apps/:id(.:format)                            opro/oauth/client_app#update
#                                          PUT        /oauth_client_apps/:id(.:format)                            opro/oauth/client_app#update
#                                          DELETE     /oauth_client_apps/:id(.:format)                            opro/oauth/client_app#destroy
#                               oauth_docs GET        /oauth_docs(.:format)                                       opro/oauth/docs#index
#                                oauth_doc GET        /oauth_docs/:id(.:format)                                   opro/oauth/docs#show
#                              oauth_tests GET        /oauth_tests(.:format)                                      opro/oauth/tests#index
#                                          POST       /oauth_tests(.:format)                                      opro/oauth/tests#create
#                               oauth_test GET        /oauth_tests/:id(.:format)                                  opro/oauth/tests#show
#                                          DELETE     /oauth_tests/:id(.:format)                                  opro/oauth/tests#destroy
#                            accept_invite GET        /users/invitation/accept(.:format)                          pending_invites#edit
#                     preview_registration POST       /welcome/preview(.:format)                                  registrations#preview
#                         new_user_session GET        /users/sign_in(.:format)                                    sessions#new
#                             user_session POST       /users/sign_in(.:format)                                    sessions#create
#                     destroy_user_session DELETE     /users/sign_out(.:format)                                   sessions#destroy
#                            user_password POST       /users/password(.:format)                                   passwords#create
#                        new_user_password GET        /users/password/new(.:format)                               passwords#new
#                       edit_user_password GET        /users/password/edit(.:format)                              passwords#edit
#                                          PATCH      /users/password(.:format)                                   passwords#update
#                                          PUT        /users/password(.:format)                                   passwords#update
#                 cancel_user_registration GET        /users/cancel(.:format)                                     devise_invitable/registrations#cancel
#                        user_registration POST       /users(.:format)                                            devise_invitable/registrations#create
#                    new_user_registration GET        /users/sign_up(.:format)                                    devise_invitable/registrations#new
#                   edit_user_registration GET        /users/edit(.:format)                                       devise_invitable/registrations#edit
#                                          PATCH      /users(.:format)                                            devise_invitable/registrations#update
#                                          PUT        /users(.:format)                                            devise_invitable/registrations#update
#                                          DELETE     /users(.:format)                                            devise_invitable/registrations#destroy
#                        user_confirmation POST       /users/confirmation(.:format)                               devise/confirmations#create
#                    new_user_confirmation GET        /users/confirmation/new(.:format)                           devise/confirmations#new
#                                          GET        /users/confirmation(.:format)                               devise/confirmations#show
#                              user_unlock POST       /users/unlock(.:format)                                     devise/unlocks#create
#                          new_user_unlock GET        /users/unlock/new(.:format)                                 devise/unlocks#new
#                                          GET        /users/unlock(.:format)                                     devise/unlocks#show
#                   accept_user_invitation GET        /users/invitation/accept(.:format)                          devise/invitations#edit
#                   remove_user_invitation GET        /users/invitation/remove(.:format)                          devise/invitations#destroy
#                          user_invitation POST       /users/invitation(.:format)                                 devise/invitations#create
#                      new_user_invitation GET        /users/invitation/new(.:format)                             devise/invitations#new
#                                          PATCH      /users/invitation(.:format)                                 devise/invitations#update
#                                          PUT        /users/invitation(.:format)                                 devise/invitations#update
#                          api_v0_expenses GET        /api/v0/expenses(.:format)                                  api/v0/expenses#index
#                                          POST       /api/v0/expenses(.:format)                                  api/v0/expenses#create
#                           api_v0_expense GET        /api/v0/expenses/:id(.:format)                              api/v0/expenses#show
#                                          PATCH      /api/v0/expenses/:id(.:format)                              api/v0/expenses#update
#                                          PUT        /api/v0/expenses/:id(.:format)                              api/v0/expenses#update
#                                          DELETE     /api/v0/expenses/:id(.:format)                              api/v0/expenses#destroy
#                           api_v0_reports GET        /api/v0/reports(.:format)                                   api/v0/reports#index
#                                          POST       /api/v0/reports(.:format)                                   api/v0/reports#create
#                            api_v0_report GET        /api/v0/reports/:id(.:format)                               api/v0/reports#show
#                                          PATCH      /api/v0/reports/:id(.:format)                               api/v0/reports#update
#                                          PUT        /api/v0/reports/:id(.:format)                               api/v0/reports#update
#                                          DELETE     /api/v0/reports/:id(.:format)                               api/v0/reports#destroy
#                    api_v0_report_comment POST       /api/v0/reports/:report_id/comment(.:format)                api/v0/reports#comment
#                    api_v0_report_retract PATCH      /api/v0/reports/:report_id/retract(.:format)                api/v0/reports#retract
#                     api_v0_report_submit PATCH      /api/v0/reports/:report_id/submit(.:format)                 api/v0/reports#submit
#                    api_v0_report_approve PATCH      /api/v0/reports/:report_id/approve(.:format)                api/v0/reports#approve
#                  api_v0_report_unapprove PATCH      /api/v0/reports/:report_id/unapprove(.:format)              api/v0/reports#unapprove
#                     api_v0_report_reject PATCH      /api/v0/reports/:report_id/reject(.:format)                 api/v0/reports#reject
#      api_v0_report_reimbursement_confirm PATCH      /api/v0/reports/:report_id/reimbursement_confirm(.:format)  api/v0/reports#reimbursement_confirm
#               api_v0_report_take_control PATCH      /api/v0/reports/:report_id/take_control(.:format)           api/v0/reports#take_control
#               api_v0_report_add_expenses POST       /api/v0/reports/:report_id/add_expenses(.:format)           api/v0/reports#add_expenses
#            api_v0_report_remove_expenses DELETE     /api/v0/reports/:report_id/remove_expenses(.:format)        api/v0/reports#remove_expenses
#             api_v0_report_reject_expense PATCH      /api/v0/reports/:report_id/reject_expense(.:format)         api/v0/reports#reject_expense
#              api_v0_report_assign_policy POST       /api/v0/reports/:report_id/assign_policy(.:format)          api/v0/reports#assign_policy
#                                          GET        /api/v0/reports(.:format)                                   api/v0/reports#index
#                                          POST       /api/v0/reports(.:format)                                   api/v0/reports#create
#                        new_api_v0_report GET        /api/v0/reports/new(.:format)                               api/v0/reports#new
#                       edit_api_v0_report GET        /api/v0/reports/:id/edit(.:format)                          api/v0/reports#edit
#                                          GET        /api/v0/reports/:id(.:format)                               api/v0/reports#show
#                                          PATCH      /api/v0/reports/:id(.:format)                               api/v0/reports#update
#                                          PUT        /api/v0/reports/:id(.:format)                               api/v0/reports#update
#                                          DELETE     /api/v0/reports/:id(.:format)                               api/v0/reports#destroy
#                          api_v0_receipts GET        /api/v0/receipts(.:format)                                  api/v0/receipts#index
#                                          POST       /api/v0/receipts(.:format)                                  api/v0/receipts#create
#                           api_v0_receipt PATCH      /api/v0/receipts/:id(.:format)                              api/v0/receipts#update
#                                          PUT        /api/v0/receipts/:id(.:format)                              api/v0/receipts#update
#                                          DELETE     /api/v0/receipts/:id(.:format)                              api/v0/receipts#destroy
#      api_v0_receipt_expense_from_receipt POST       /api/v0/receipts/:receipt_id/expense_from_receipt(.:format) api/v0/receipts#expense_from_receipt
#                                          GET        /api/v0/receipts(.:format)                                  api/v0/receipts#index
#                                          POST       /api/v0/receipts(.:format)                                  api/v0/receipts#create
#                       new_api_v0_receipt GET        /api/v0/receipts/new(.:format)                              api/v0/receipts#new
#                      edit_api_v0_receipt GET        /api/v0/receipts/:id/edit(.:format)                         api/v0/receipts#edit
#                                          GET        /api/v0/receipts/:id(.:format)                              api/v0/receipts#show
#                                          PATCH      /api/v0/receipts/:id(.:format)                              api/v0/receipts#update
#                                          PUT        /api/v0/receipts/:id(.:format)                              api/v0/receipts#update
#                                          DELETE     /api/v0/receipts/:id(.:format)                              api/v0/receipts#destroy
#          api_v0_configuration_categories GET        /api/v0/configuration/categories(.:format)                  api/v0/configuration/category#index
#        api_v0_configuration_gcm_register POST       /api/v0/configuration/gcm/register(.:format)                api/v0/configuration/gcm#create
#      api_v0_configuration_gcm_unregister POST       /api/v0/configuration/gcm/unregister(.:format)              api/v0/configuration/gcm#delete
#                          api_v1_expenses GET        /api/v1/expenses(.:format)                                  api/v1/expenses#index
#                                          POST       /api/v1/expenses(.:format)                                  api/v1/expenses#create
#                           api_v1_expense GET        /api/v1/expenses/:id(.:format)                              api/v1/expenses#show
#                                          PATCH      /api/v1/expenses/:id(.:format)                              api/v1/expenses#update
#                                          PUT        /api/v1/expenses/:id(.:format)                              api/v1/expenses#update
#                                          DELETE     /api/v1/expenses/:id(.:format)                              api/v1/expenses#destroy
#                           api_v1_reports GET        /api/v1/reports(.:format)                                   api/v1/reports#index
#                                          POST       /api/v1/reports(.:format)                                   api/v1/reports#create
#                            api_v1_report GET        /api/v1/reports/:id(.:format)                               api/v1/reports#show
#                                          PATCH      /api/v1/reports/:id(.:format)                               api/v1/reports#update
#                                          PUT        /api/v1/reports/:id(.:format)                               api/v1/reports#update
#                                          DELETE     /api/v1/reports/:id(.:format)                               api/v1/reports#destroy
#                    api_v1_report_comment POST       /api/v1/reports/:report_id/comment(.:format)                api/v1/reports#comment
#                                          GET        /api/v1/reports(.:format)                                   api/v1/reports#index
#                                          POST       /api/v1/reports(.:format)                                   api/v1/reports#create
#                        new_api_v1_report GET        /api/v1/reports/new(.:format)                               api/v1/reports#new
#                       edit_api_v1_report GET        /api/v1/reports/:id/edit(.:format)                          api/v1/reports#edit
#                                          GET        /api/v1/reports/:id(.:format)                               api/v1/reports#show
#                                          PATCH      /api/v1/reports/:id(.:format)                               api/v1/reports#update
#                                          PUT        /api/v1/reports/:id(.:format)                               api/v1/reports#update
#                                          DELETE     /api/v1/reports/:id(.:format)                               api/v1/reports#destroy
#                    api_v1_money_requests GET        /api/v1/money_requests(.:format)                            api/v1/money_requests#index
#                                          POST       /api/v1/money_requests(.:format)                            api/v1/money_requests#create
#                     api_v1_money_request GET        /api/v1/money_requests/:id(.:format)                        api/v1/money_requests#show
#                                          PATCH      /api/v1/money_requests/:id(.:format)                        api/v1/money_requests#update
#                                          PUT        /api/v1/money_requests/:id(.:format)                        api/v1/money_requests#update
#                                          DELETE     /api/v1/money_requests/:id(.:format)                        api/v1/money_requests#destroy
#             api_v1_money_request_comment POST       /api/v1/money_requests/:money_request_id/comment(.:format)  api/v1/money_requests#comment
#                                          GET        /api/v1/money_requests(.:format)                            api/v1/money_requests#index
#                                          POST       /api/v1/money_requests(.:format)                            api/v1/money_requests#create
#                 new_api_v1_money_request GET        /api/v1/money_requests/new(.:format)                        api/v1/money_requests#new
#                edit_api_v1_money_request GET        /api/v1/money_requests/:id/edit(.:format)                   api/v1/money_requests#edit
#                                          GET        /api/v1/money_requests/:id(.:format)                        api/v1/money_requests#show
#                                          PATCH      /api/v1/money_requests/:id(.:format)                        api/v1/money_requests#update
#                                          PUT        /api/v1/money_requests/:id(.:format)                        api/v1/money_requests#update
#                                          DELETE     /api/v1/money_requests/:id(.:format)                        api/v1/money_requests#destroy
#                          api_v1_receipts GET        /api/v1/receipts(.:format)                                  api/v1/receipts#index
#                                          POST       /api/v1/receipts(.:format)                                  api/v1/receipts#create
#                           api_v1_receipt PATCH      /api/v1/receipts/:id(.:format)                              api/v1/receipts#update
#                                          PUT        /api/v1/receipts/:id(.:format)                              api/v1/receipts#update
#                                          DELETE     /api/v1/receipts/:id(.:format)                              api/v1/receipts#destroy
#                  api_v1_receipt_add_note POST       /api/v1/receipts/:receipt_id/add_note(.:format)             api/v1/receipts#add_note
#      api_v1_receipt_expense_from_receipt POST       /api/v1/receipts/:receipt_id/expense_from_receipt(.:format) api/v1/receipts#expense_from_receipt
#                                          GET        /api/v1/receipts(.:format)                                  api/v1/receipts#index
#                                          POST       /api/v1/receipts(.:format)                                  api/v1/receipts#create
#                       new_api_v1_receipt GET        /api/v1/receipts/new(.:format)                              api/v1/receipts#new
#                      edit_api_v1_receipt GET        /api/v1/receipts/:id/edit(.:format)                         api/v1/receipts#edit
#                                          GET        /api/v1/receipts/:id(.:format)                              api/v1/receipts#show
#                                          PATCH      /api/v1/receipts/:id(.:format)                              api/v1/receipts#update
#                                          PUT        /api/v1/receipts/:id(.:format)                              api/v1/receipts#update
#                                          DELETE     /api/v1/receipts/:id(.:format)                              api/v1/receipts#destroy
#                             api_v1_users GET        /api/v1/users(.:format)                                     api/v1/users#index
#                              api_v1_user GET        /api/v1/users/:id(.:format)                                 api/v1/users#show
#                 api_v1_user_user_summary GET        /api/v1/users/:user_id/summary(.:format)                    api/v1/users#summary
#                                          GET        /api/v1/users(.:format)                                     api/v1/users#index
#                                          POST       /api/v1/users(.:format)                                     api/v1/users#create
#                          new_api_v1_user GET        /api/v1/users/new(.:format)                                 api/v1/users#new
#                         edit_api_v1_user GET        /api/v1/users/:id/edit(.:format)                            api/v1/users#edit
#                                          GET        /api/v1/users/:id(.:format)                                 api/v1/users#show
#                                          PATCH      /api/v1/users/:id(.:format)                                 api/v1/users#update
#                                          PUT        /api/v1/users/:id(.:format)                                 api/v1/users#update
#                                          DELETE     /api/v1/users/:id(.:format)                                 api/v1/users#destroy
#              api_v1_cards_balance_update POST       /api/v1/cards/balance/update(.:format)                      api/v1/cards#update_balance
#               api_v1_cards_status_update POST       /api/v1/cards/status/update(.:format)                       api/v1/cards#update_status
#          api_v1_configuration_categories GET        /api/v1/configuration/categories(.:format)                  api/v1/configuration/category#index
#        api_v1_configuration_gcm_register POST       /api/v1/configuration/gcm/register(.:format)                api/v1/configuration/gcm#create
#      api_v1_configuration_gcm_unregister POST       /api/v1/configuration/gcm/unregister(.:format)              api/v1/configuration/gcm#delete
#                          api_v1_balances GET        /api/v1/balances(.:format)                                  api/v1/users#balance
#                   policies_expense_rules GET        /policies/expense_rules(.:format)                           policies#expense_rules
#                    policies_budget_rules GET        /policies/budget_rules(.:format)                            policies#budget_rules
#                  policies_policy_members GET        /policies/policy_members(.:format)                          policies#policy_members
#                     policies_create_rule GET        /policies/create_rule(.:format)                             policies#create_rule
#          policies_policy_member_settings GET        /policies/policy_member_settings(.:format)                  policies#policy_member_settings
#                         policies_details GET        /policies/details(.:format)                                 policies#details
#                                 policies GET        /policies(.:format)                                         policies#index
#                                          POST       /policies(.:format)                                         policies#create
#                                   policy GET        /policies/:id(.:format)                                     policies#show
#                                          PATCH      /policies/:id(.:format)                                     policies#update
#                                          PUT        /policies/:id(.:format)                                     policies#update
#                                          DELETE     /policies/:id(.:format)                                     policies#destroy
#                   policy_invitable_users POST       /policies/:policy_id/invitable_users(.:format)              policies#invitable_users
#                         policy_add_users POST       /policies/:policy_id/add_users(.:format)                    policies#add_users
#                      policy_remove_users POST       /policies/:policy_id/remove_users(.:format)                 policies#remove_users
#         policy_update_user_configuration PATCH      /policies/:policy_id/update_users_configuration(.:format)   policies#update_user_configuration
#                   policy_destroy_mapping DELETE     /policies/:policy_id/remove_mapping/:mapping_id(.:format)   policies#destrot_mapping
#                          policy_add_rule POST       /policies/:policy_id/add_rule(.:format)                     rules#create
#                       policy_remove_rule DELETE     /policies/:policy_id/remove_rule(.:format)                  rules#destroy
#                                          GET        /policies(.:format)                                         policies#index
#                                          POST       /policies(.:format)                                         policies#create
#                               new_policy GET        /policies/new(.:format)                                     policies#new
#                              edit_policy GET        /policies/:id/edit(.:format)                                policies#edit
#                                          GET        /policies/:id(.:format)                                     policies#show
#                                          PATCH      /policies/:id(.:format)                                     policies#update
#                                          PUT        /policies/:id(.:format)                                     policies#update
#                                          DELETE     /policies/:id(.:format)                                     policies#destroy
#                               categories GET        /categories(.:format)                                       categories#index
#                                          POST       /categories(.:format)                                       categories#create
#                             new_category GET        /categories/new(.:format)                                   categories#new
#                            edit_category GET        /categories/:id/edit(.:format)                              categories#edit
#                                 category GET        /categories/:id(.:format)                                   categories#show
#                                          PATCH      /categories/:id(.:format)                                   categories#update
#                                          PUT        /categories/:id(.:format)                                   categories#update
#                                          DELETE     /categories/:id(.:format)                                   categories#destroy
#                       export_preferences GET        /export_preferences(.:format)                               export_preferences#index
#                                          POST       /export_preferences(.:format)                               export_preferences#create
#                    new_export_preference GET        /export_preferences/new(.:format)                           export_preferences#new
#                   edit_export_preference GET        /export_preferences/:id/edit(.:format)                      export_preferences#edit
#                        export_preference GET        /export_preferences/:id(.:format)                           export_preferences#show
#                                          PATCH      /export_preferences/:id(.:format)                           export_preferences#update
#                                          PUT        /export_preferences/:id(.:format)                           export_preferences#update
#                                          DELETE     /export_preferences/:id(.:format)                           export_preferences#destroy
#                        card_restrictions GET        /card_restrictions(.:format)                                card_restrictions#index
#                                          POST       /card_restrictions(.:format)                                card_restrictions#create
#                     new_card_restriction GET        /card_restrictions/new(.:format)                            card_restrictions#new
#                    edit_card_restriction GET        /card_restrictions/:id/edit(.:format)                       card_restrictions#edit
#                         card_restriction GET        /card_restrictions/:id(.:format)                            card_restrictions#show
#                                          PATCH      /card_restrictions/:id(.:format)                            card_restrictions#update
#                                          PUT        /card_restrictions/:id(.:format)                            card_restrictions#update
#                                          DELETE     /card_restrictions/:id(.:format)                            card_restrictions#destroy
#                         companies_notify GET        /companies/notify(.:format)                                 companies#notify
#                      company_add_balance POST       /companies/:company_id/add_balance(.:format)                companies#add_balance
#                                companies GET        /companies(.:format)                                        companies#index
#                                          POST       /companies(.:format)                                        companies#create
#                              new_company GET        /companies/new(.:format)                                    companies#new
#                             edit_company GET        /companies/:id/edit(.:format)                               companies#edit
#                                  company GET        /companies/:id(.:format)                                    companies#show
#                                          PATCH      /companies/:id(.:format)                                    companies#update
#                                          PUT        /companies/:id(.:format)                                    companies#update
#                                          DELETE     /companies/:id(.:format)                                    companies#destroy
#       organization_account_policies_list GET        /organization_account/policies_list(.:format)               organization_account#policies_list
#          organization_account_categories GET        /organization_account/categories(.:format)                  organization_account#categories
#  organization_account_export_preferences GET        /organization_account/export_preferences(.:format)          organization_account#export_preferences
#                             add_category POST       /add_category(.:format)                                     organization_account#add_category
#                          remove_category DELETE     /remove_category(.:format)                                  organization_account#remove_category
#                 update_export_preference PATCH      /export/:id/update(.:format)                                organization_account#update_export_column
#                         add_export_field POST       /add_export_field(.:format)                                 organization_account#add_export_column
#                      delete_export_field DELETE     /remove_export_field(.:format)                              organization_account#remove_export_column
#                                   people GET        /people(.:format)                                           people#people
#                            verify_mobile GET        /users/verify(.:format)                                     otp#edit
#                     update_mobile_number POST       /otp/update(.:format)                                       otp#update
#                               verify_otp POST       /otp/verify(.:format)                                       otp#verify
#                               resend_otp POST       /otp/resend(.:format)                                       otp#resend
#                             card_details POST       /cards/details(.:format)                                    cards#details
#                           update_balance POST       /cards/update_balance(.:format)                             cards#update_balance
#                       update_card_status POST       /cards/update_status(.:format)                              cards#update_status
#                                  reports GET        /reports(.:format)                                          reports#index
#                                          POST       /reports(.:format)                                          reports#create
#                                   report GET        /reports/:id(.:format)                                      reports#show
#                                          PATCH      /reports/:id(.:format)                                      reports#update
#                                          PUT        /reports/:id(.:format)                                      reports#update
#                                          DELETE     /reports/:id(.:format)                                      reports#destroy
#                            export_report GET        /export/report(.:format)                                    export#report
#                           report_comment POST       /reports/:report_id/comment(.:format)                       reports#comment
#                           report_retract PATCH      /reports/:report_id/retract(.:format)                       reports#retract
#                            report_submit PATCH      /reports/:report_id/submit(.:format)                        reports#submit
#                           report_approve PATCH      /reports/:report_id/approve(.:format)                       reports#approve
#                         report_unapprove PATCH      /reports/:report_id/unapprove(.:format)                     reports#unapprove
#                            report_reject PATCH      /reports/:report_id/reject(.:format)                        reports#reject
#                    report_reject_expense PATCH      /reports/:report_id/reject_expense(.:format)                reports#reject_expense
#             report_reimbursement_confirm PATCH      /reports/:report_id/reimbursement_confirm(.:format)         reports#reimbursement_confirm
#                      report_take_control PATCH      /reports/:report_id/take_control(.:format)                  reports#take_control
#                      report_add_expenses POST       /reports/:report_id/add_expenses(.:format)                  reports#add_expenses
#                   report_remove_expenses DELETE     /reports/:report_id/remove_expenses(.:format)               reports#remove_expenses
#                                          GET        /reports(.:format)                                          reports#index
#                                          POST       /reports(.:format)                                          reports#create
#                               new_report GET        /reports/new(.:format)                                      reports#new
#                              edit_report GET        /reports/:id/edit(.:format)                                 reports#edit
#                                          GET        /reports/:id(.:format)                                      reports#show
#                                          PATCH      /reports/:id(.:format)                                      reports#update
#                                          PUT        /reports/:id(.:format)                                      reports#update
#                                          DELETE     /reports/:id(.:format)                                      reports#destroy
#                      money_request_index GET        /money_request(.:format)                                    money_request#index
#                                          POST       /money_request(.:format)                                    money_request#create
#                            money_request GET        /money_request/:id(.:format)                                money_request#show
#                                          PATCH      /money_request/:id(.:format)                                money_request#update
#                                          PUT        /money_request/:id(.:format)                                money_request#update
#                                          DELETE     /money_request/:id(.:format)                                money_request#destroy
#                    money_request_comment POST       /money_request/:money_request_id/comment(.:format)          money_request#comment
#                                          GET        /money_request(.:format)                                    money_request#index
#                                          POST       /money_request(.:format)                                    money_request#create
#                        new_money_request GET        /money_request/new(.:format)                                money_request#new
#                       edit_money_request GET        /money_request/:id/edit(.:format)                           money_request#edit
#                                          GET        /money_request/:id(.:format)                                money_request#show
#                                          PATCH      /money_request/:id(.:format)                                money_request#update
#                                          PUT        /money_request/:id(.:format)                                money_request#update
#                                          DELETE     /money_request/:id(.:format)                                money_request#destroy
#                   expense_attach_receipt POST       /expenses/:expense_id/attach_receipt(.:format)              expenses#attach_receipt
#                   expense_detach_receipt POST       /expenses/:expense_id/detach_receipt(.:format)              expenses#detach_receipt
#                      expense_add_receipt POST       /expenses/:expense_id/add_receipt(.:format)                 expenses#add_receipt
#                                 expenses GET        /expenses(.:format)                                         expenses#index
#                                          POST       /expenses(.:format)                                         expenses#create
#                              new_expense GET        /expenses/new(.:format)                                     expenses#new
#                             edit_expense GET        /expenses/:id/edit(.:format)                                expenses#edit
#                                  expense GET        /expenses/:id(.:format)                                     expenses#show
#                                          PATCH      /expenses/:id(.:format)                                     expenses#update
#                                          PUT        /expenses/:id(.:format)                                     expenses#update
#                                          DELETE     /expenses/:id(.:format)                                     expenses#destroy
#                      expenses_unreported POST       /expenses/unreported(.:format)                              expenses#unreported
#                         receipt_add_note POST       /receipts/:receipt_id/add_note(.:format)                    receipts#add_note
#                                 receipts GET        /receipts(.:format)                                         receipts#index
#                                          POST       /receipts(.:format)                                         receipts#create
#                              new_receipt GET        /receipts/new(.:format)                                     receipts#new
#                             edit_receipt GET        /receipts/:id/edit(.:format)                                receipts#edit
#                                  receipt GET        /receipts/:id(.:format)                                     receipts#show
#                                          PATCH      /receipts/:id(.:format)                                     receipts#update
#                                          PUT        /receipts/:id(.:format)                                     receipts#update
#                                          DELETE     /receipts/:id(.:format)                                     receipts#destroy
#                     expense_from_receipt POST       /expense_from_receipt(.:format)                             receipts#expense_from_receipt
#                       users_get_managers GET        /users/get_managers(.:format)                               users#get_managers
#                       users_user_profile GET        /users/user_profile(.:format)                               users#user_profile
#                       users_user_balance GET        /users/user_balance(.:format)                               users#user_balance
#                      users_user_security GET        /users/user_security(.:format)                              users#user_security
#                                   lookup GET        /lookup(.:format)                                           users#lookup
#                    send_verification_otp POST       /send_verification_otp(.:format)                            users#send_verification_otp
#                          verify_user_otp POST       /verify_user_otp(.:format)                                  users#verify_user_otp
#                             set_password POST       /set_password(.:format)                                     users#set_new_password
#                                    users GET        /users(.:format)                                            users#index
#                                          POST       /users(.:format)                                            users#create
#                                     user GET        /users/:id(.:format)                                        users#show
#                                          PATCH      /users/:id(.:format)                                        users#update
#                                          PUT        /users/:id(.:format)                                        users#update
#                                          DELETE     /users/:id(.:format)                                        users#destroy
#                             user_details POST       /users/:user_id/user_details(.:format)                      users#user_details
#                         user_update_team PATCH      /users/:user_id/update_user_team(.:format)                  users#update_team
#                         user_update_role PATCH      /users/:user_id/update_role(.:format)                       users#update_user_role
#                             user_profile GET        /users/:user_id/profile(.:format)                           users#profile
#                     user_update_password POST       /users/:user_id/update_password(.:format)                   users#update_password
#                             user_balance GET        /users/:user_id/balance(.:format)                           users#balance
#           user_verify_reset_password_otp GET        /users/:user_id/verify_reset_otp(.:format)                  users#verify_reset_password_otp
#                                          GET        /users(.:format)                                            users#index
#                                          POST       /users(.:format)                                            users#create
#                                 new_user GET        /users/new(.:format)                                        users#new
#                                edit_user GET        /users/:id/edit(.:format)                                   users#edit
#                                          GET        /users/:id(.:format)                                        users#show
#                                          PATCH      /users/:id(.:format)                                        users#update
#                                          PUT        /users/:id(.:format)                                        users#update
#                                          DELETE     /users/:id(.:format)                                        users#destroy
#                              user_import POST       /import(.:format)                                           users#import
#                        superadmin_import POST       /superadmin_import(.:format)                                superadmin/companies#import
#                      initiate_activation GET        /pending_invites/initiate_activation(.:format)              pending_invites#initiate_activation
#                        activate_employee GET        /pending_invites/activate_employee(.:format)                pending_invites#activate_employee
#                                 send_otp GET        /pending_invites/send_otp(.:format)                         pending_invites#send_otp
#               manager_activation_sign_up PATCH      /pending_invites/manager_sign_up(.:format)                  pending_invites#manager_sign_up
#                  update_default_password POST       /users/update_default_password(.:format)                    users#update_default_password
#                    edit_default_password GET        /edit_default_password(.:format)                            users#edit_default_password
#                          pending_invites POST       /pending_invites(.:format)                                  pending_invites#create
#                      edit_pending_invite GET        /pending_invites/:id/edit(.:format)                         pending_invites#edit
#                           pending_invite PATCH      /pending_invites/:id(.:format)                              pending_invites#update
#                                          PUT        /pending_invites/:id(.:format)                              pending_invites#update
#                                          DELETE     /pending_invites/:id(.:format)                              pending_invites#destroy
#                    pending_invite_accept PATCH      /pending_invites/:pending_invite_id/accept(.:format)        pending_invites#accept
#                                          GET        /pending_invites(.:format)                                  pending_invites#index
#                                          POST       /pending_invites(.:format)                                  pending_invites#create
#                       new_pending_invite GET        /pending_invites/new(.:format)                              pending_invites#new
#                                          GET        /pending_invites/:id/edit(.:format)                         pending_invites#edit
#                                          GET        /pending_invites/:id(.:format)                              pending_invites#show
#                                          PATCH      /pending_invites/:id(.:format)                              pending_invites#update
#                                          PUT        /pending_invites/:id(.:format)                              pending_invites#update
#                                          DELETE     /pending_invites/:id(.:format)                              pending_invites#destroy
#                      settlements_summary GET        /settlements/summary(.:format)                              settlements#summary
#                              settlements GET        /settlements(.:format)                                      settlements#index
#                                          POST       /settlements(.:format)                                      settlements#create
#                           new_settlement GET        /settlements/new(.:format)                                  settlements#new
#                          edit_settlement GET        /settlements/:id/edit(.:format)                             settlements#edit
#                               settlement GET        /settlements/:id(.:format)                                  settlements#show
#                                          PATCH      /settlements/:id(.:format)                                  settlements#update
#                                          PUT        /settlements/:id(.:format)                                  settlements#update
#                                          DELETE     /settlements/:id(.:format)                                  settlements#destroy
#                   settlement_add_payment POST       /settlements/:id/add_payment(.:format)                      settlements#add_payment
#                                          GET        /receipts(.:format)                                         receipts#index
#                                          POST       /receipts(.:format)                                         receipts#create
#                                          GET        /receipts/new(.:format)                                     receipts#new
#                                          GET        /receipts/:id/edit(.:format)                                receipts#edit
#                                          GET        /receipts/:id(.:format)                                     receipts#show
#                                          PATCH      /receipts/:id(.:format)                                     receipts#update
#                                          PUT        /receipts/:id(.:format)                                     receipts#update
#                                          DELETE     /receipts/:id(.:format)                                     receipts#destroy
#             superadmin_company_new_admin POST       /superadmin/companies/:company_id/add_admin(.:format)       superadmin/companies#add_admin
#                 superadmin_company_users GET        /superadmin/companies/:company_id/users(.:format)           superadmin/users#index
#                                          POST       /superadmin/companies/:company_id/users(.:format)           superadmin/users#create
#              new_superadmin_company_user GET        /superadmin/companies/:company_id/users/new(.:format)       superadmin/users#new
#             edit_superadmin_company_user GET        /superadmin/companies/:company_id/users/:id/edit(.:format)  superadmin/users#edit
#                  superadmin_company_user GET        /superadmin/companies/:company_id/users/:id(.:format)       superadmin/users#show
#                                          PATCH      /superadmin/companies/:company_id/users/:id(.:format)       superadmin/users#update
#                                          PUT        /superadmin/companies/:company_id/users/:id(.:format)       superadmin/users#update
#                                          DELETE     /superadmin/companies/:company_id/users/:id(.:format)       superadmin/users#destroy
#                     superadmin_companies GET        /superadmin/companies(.:format)                             superadmin/companies#index
#                                          POST       /superadmin/companies(.:format)                             superadmin/companies#create
#                   new_superadmin_company GET        /superadmin/companies/new(.:format)                         superadmin/companies#new
#                  edit_superadmin_company GET        /superadmin/companies/:id/edit(.:format)                    superadmin/companies#edit
#                       superadmin_company GET        /superadmin/companies/:id(.:format)                         superadmin/companies#show
#                                          PATCH      /superadmin/companies/:id(.:format)                         superadmin/companies#update
#                                          PUT        /superadmin/companies/:id(.:format)                         superadmin/companies#update
#                                          DELETE     /superadmin/companies/:id(.:format)                         superadmin/companies#destroy
#       statements_company_balance_summary GET        /statements/company_balance_summary(.:format)               statements#company_balance_summary
#  statements_company_transactions_summary GET        /statements/company_transactions_summary(.:format)          statements#company_transactions_summary
#      statements_company_policies_summary GET        /statements/company_policies_summary(.:format)              statements#company_policies_summary
#                                          GET        /statements/:id/summary(.:format)                           statements#summary
#                         export_statement GET        /export/:id/statements(.:format)                            export#statement
#                               statements GET        /statements(.:format)                                       statements#index
#                                          POST       /statements(.:format)                                       statements#create
#                            new_statement GET        /statements/new(.:format)                                   statements#new
#                           edit_statement GET        /statements/:id/edit(.:format)                              statements#edit
#                                statement GET        /statements/:id(.:format)                                   statements#show
#                                          PATCH      /statements/:id(.:format)                                   statements#update
#                                          PUT        /statements/:id(.:format)                                   statements#update
#                                          DELETE     /statements/:id(.:format)                                   statements#destroy
#                                     root GET        /                                                           home#index
#                                  welcome GET        /welcome(.:format)                                          home#welcome
#                                    about GET        /about(.:format)                                            home#about
#                    autocomplete_merchant GET        /autocomplete/merchant(.:format)                            autocomplete#merchant
#                        autocomplete_user GET        /autocomplete/user(.:format)                                autocomplete#user
#                      external_url_report GET        /external/reports/:id(.:format)                             external_url#report
#               external_url_money_request GET        /external/requests/:id(.:format)                            external_url#money_request
#                  external_url_settlement GET        /external/settlements/:id(.:format)                         external_url#payment
#                                analytics GET        /analytics(.:format)                                        analytics#show
#                                          GET        /companies/notify(.:format)                                 companies#notify
#                            notifications GET        /notifications(.:format)                                    notifications#index
#                     notifications_unread GET        /notifications/unread(.:format)                             notifications#unread
#              notifications_mark_all_read GET        /notifications/mark_all_read(.:format)                      notifications#mark_all_read
#                                     faqs GET        /faqs(.:format)                                             faqs#index
#

Rails.application.routes.draw do


  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
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
  # get 'policies' => 'policies#index'

  get '/users/invitation/accept', to: 'pending_invites#edit', as: :accept_invite

  post '/welcome/preview', to: 'registrations#preview', as: :preview_registration

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
        patch 'reimbursement_confirm' => 'reports#reimbursement_confirm', as: :reimbursement_confirm
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
    end
  end


  get 'policies/expense_rules' => 'policies#expense_rules'
  get 'policies/budget_rules' => 'policies#budget_rules'
  get 'policies/policy_members' => 'policies#policy_members'
  get 'policies/create_rule' => 'policies#create_rule'
  get 'policies/policy_member_settings/' => 'policies#policy_member_settings'

  get 'policies/details' => 'policies#details'
  resources :policies, except: [:new, :edit]
  resources :policies do
    post 'invitable_users' => 'policies#invitable_users', as: :invitable_users
    post 'add_users' => 'policies#add_users', as: :add_users
    post 'remove_users' => 'policies#remove_users', as: :remove_users
    patch 'update_users_configuration' => 'policies#update_user_configuration', as: :update_user_configuration
    delete 'remove_mapping/:mapping_id' => 'policies#destrot_mapping', as: :destroy_mapping
    post 'add_rule', to: 'rules#create', as: :add_rule
    delete 'remove_rule', to: 'rules#destroy', as: :remove_rule
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
    patch 'reimbursement_confirm' => 'reports#reimbursement_confirm', as: :reimbursement_confirm
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
  end
  post 'expenses/unreported', to: 'expenses#unreported', as: :expenses_unreported

  resources :receipts do
    post 'add_note', to: 'receipts#add_note', as: :add_note
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
    post 'user_details', to: 'users#user_details', as: :details
    patch 'update_user_team', to: 'users#update_team', as: :update_team
    patch 'update_role', to: 'users#update_user_role', as: :update_role
    get 'profile', to: 'users#profile', as: :profile
    post 'update_password', to: 'users#update_password', as: :update_password
    get 'balance', to: 'users#balance', as: :balance
    get 'verify_reset_otp', to: 'users#verify_reset_password_otp', as: :verify_reset_password_otp
  end

  # routes for testing import
  # get 'mass_import', to: 'users#mass_import', as: :mass_import
  post 'import', to: 'users#import', as: :user_import
  post 'superadmin_import', to: 'superadmin/companies#import', as: :superadmin_import
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

  namespace :superadmin do
    resources :companies do
      post 'add_admin', to: 'companies#add_admin', as: :new_admin
      resources :users
    end
  end


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
