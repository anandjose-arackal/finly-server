# == Route Map
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

  ######### FINLY COLLECT START ###########
  post 'collect/notify', to: 'finly_collect#notify'
  post 'collect/test_transaction', to: 'finly_collect#notify'
  ######### FINLY COLLECT END ###########

  ######### GEMS SPECIFIC START ###########

  # mount HealthMonitor::Engine, at: '/health/'

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
      patch 'money_requests/credit_cash', to: 'money_request#credit_cash', as: :credit
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
      get 'available_expense_types', to: 'expenses#available_expense_types'
    end

    namespace :v1 do
      post 'auth', to: 'token#create'
      get 'configuration/category'
      resources :expenses, only: [:index, :show, :create, :update, :destroy]
      resources :reports, only: [:create, :index, :show, :update, :destroy]
      resources :reports do
        post 'comment' => 'reports#comment', as: :comment
      end
      patch 'money_requests/credit_cash', to: 'money_request#credit_cash', as: :credit
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

    namespace :v2 do
      get 'available_expense_types', to: 'expenses#available_expense_types'
      resources :expenses, only: [:index, :show, :create, :update, :destroy]
      resources :reports, only: [:create, :show, :update]
      resources :reports do
        post 'comment' => 'reports#comment', as: :comment
      end
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
        patch 'users/deactivate/:id', to: 'users#deactivate_user'
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

  ######### DESKTOP START ###########
  namespace :desktop do
    namespace :v1 do
      post 'desktop_users', to: 'desktop_users#create'
    end
  end

  ######### DESKTOP END ###########

  ######### ADMIN PANEL START ###########

  namespace :transcriber do
    post 'expenses/create', to: 'receipts#create_expense', as: :transcribed_expenses_create
    patch 'expenses/:id/update', to: 'receipts#update_expense', as: :transcribed_expenses_update
    get 'expenses/:id/show', to: 'receipts#show', as: :transcribed_receipt_show
    get 'companies/:id', to: 'companies#show', as: :untranscribed_receipts
    get 'companies', to: 'companies#index', as: :companies
    get 'expenses/currencies', to: 'expenses#currencies'
    resources :expenses
    resources :companies
    get 'receipts/count', to: 'receipts#count', as: :count
    resources :receipts
  end

  namespace :admin_users do
    get 'companies/count', to: 'companies#count'
    resources :companies do
      post 'dcode_check', to: 'companies#check_dcode'
      post 'configure_payu', to: 'companies#configure_payu'
    end
    get 'company_types', to: 'companies#company_types'
    get 'users/count', to: 'users#count'
    resources :users do
      patch 'update_status', to: 'users#update_status', as: :update_status
      patch 'update_mapping', to: 'users#update_mapping', as: :update_mapping
      delete 'destroy_mapping', to: 'users#destroy_mapping', as: :destroy_mapping
      patch 'update_panel', to: 'users#update_panel', as: :update_panel
      patch 'reset_password', to: 'users#reset_password', as: :reset_password
    end
    post 'welcome', to: 'users#admin_welcome', as: :welcome
    post 'agreements_mail', to: 'users#agreements_mail', as: :agreements_mail
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

    post 'cards/bulk_assign', to: 'cards#bulk_assign', as: :bulk_assign

    post 'call_center/search', to: 'call_center/users#search', as: :search
  end

  get 'admin_menus', to: 'admin_users/users#admin_menus', as: :admin_menu

  ######### ADMIN PANEL END ###########

  ################### API Callbacks tester ######################

  namespace :api do
    post 'callbacks/successful_vendor_payment', to: 'callbacks#successful_vendor_payment', as: :successful_vendor_payment
    post 'callbacks/invoice_payment_received', to: 'callbacks#invoice_payment_received', as: :invoice_payment_received
  end

  ############# Virtual Bank Accounts and Collect API Start ######################

  get 'virtual_accounts/:account_number', to: 'api/fc/invoices/virtual_bank_accounts#show'
  post 'virtual_accounts', to: 'api/fc/invoices/virtual_bank_accounts#create'
  patch 'virtual_accounts/:account_number', to: 'api/fc/invoices/virtual_bank_accounts#update'
  delete 'virtual_accounts/:account_number', to: 'api/fc/invoices/virtual_bank_accounts#deactivate'
  post 'invoices', to: 'api/fc/invoices/outward_invoices#create_valid'
  post 'invoices/customers', to: 'api/fc/invoices/customers#create'
  patch 'invoices/customers/:id', to: 'api/fc/invoices/customers#update'
  get 'invoices/customers/:id', to: 'api/fc/invoices/customers#show'

  ############### Virtual Bank Accounts and Collect API End ######################

  ################### Vendor Payments APIs start #####################

  namespace :api do
    namespace :vp do
      namespace :bank_transfer do
        post 'initiate_payment', to: 'bank_payment_requests#initiate_payment', as: :initiate_payment
        get 'payment_status/:id', to: 'bank_payment_requests#payment_status', as: :payment_status
        post 'bulk_initiate_payment', to: 'bank_payment_requests#bulk_initiate_payment', as: :bulk_initiate_payment
        resources :bank_payment_requests do
          patch 'credit', to: 'bank_payment_requests#credit', as: :credit
          patch 'review', to: 'bank_payment_requests#review', as: :review
        end
      end
      namespace :v1 do
        resources :inventory_line_items
        resources :inward_invoice_attachments
        patch 'bank_accounts/disable', to: 'bank_accounts#disable', as: :bank_account_disable
        resources :bank_accounts
      end
      scope :vendors do
        post '', to: 'vendors#create'
      end
    end
  end

  ################### Vendor Payments APIs end ########################

  get 'junk/show', to: 'junk#show'

  get 'menu_data', to: 'users#menu_data'

  # adding admin oauth token creation for admin login
  post 'admin/oauth/token', to: 'admin_users/oauth/token#create', as: :admin_oauth_token_generate, defaults: {format: 'json'}
  post 'admin/oauth/bypass_token', to: 'admin_users/oauth/bypass_token#create', defaults: {format: 'json'}

  post '/welcome/preview', to: 'registrations#preview', as: :preview_registration
  post 'welcome/signup', to: 'registrations#signup', as: :welcome_signup
  post 'welcome/pricing', to: 'registrations#pricing', as: :welcome_pricing
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
    resources :vehicle_rates, controller: 'vehicle_rates', only: [:create, :destroy]
  end

  resources :user_permissions do
    post 'check_permissions', to: 'user_permissions#check_permissions', as: :check_permissions
  end

  resources :categories do
    get 'sub_categories', to: 'categories#sub_categories', as: :sub_categories
  end

  resources :export_preferences

  resources :card_restrictions

  get 'companies/notify', to: 'companies#notify'
  get 'companies/load_options', to: 'companies#load_options', as: :load_options
  get 'companies/categories_and_cost_centers', to: 'companies#categories_and_cost_centers'
  resources :companies do
    post 'add_balance', to: 'companies#add_balance', as: :add_balance
    resources :locations
  end

  resources :user_pockets
  get 'assignable_pockets/:selected_user_id', to: 'user_pockets#assignable_pockets'
  post 'assign_pockets', to: 'user_pockets#assign_pocket', as: :assign_pocket

  # get 'organization_account' => 'organization_account#show'
  get 'organization_account/sidebar_menu_config' => 'organization_account#sidebar_menu_config'
  get 'organization_account/policies_list' => 'organization_account#policies_list'
  get 'organization_account/categories' => 'organization_account#categories'
  get 'organization_account/export_preferences' => 'organization_account#export_preferences'
  get 'state_codes', to: 'organization_account#gst_state_codes', as: :state_codes

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

  delete 'reports/destroy', to: 'reports#destroy'
  resources :reports, except: [:new, :edit]
  get 'export/report(.:format)' => 'export#report', as: :export_report
  get 'export/templates/index' => 'export#index_template'
  get 'export/templates/:template_key' => 'export#export_template'

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


  post 'money_requests/categories', to: 'money_request_category#create'
  get 'money_requests/categories', to: 'money_request_category#index'
  delete 'money_requests/categories/:id', to: 'money_request_category#destroy'
  patch 'money_requests/credit_cash', to: 'money_request#credit_cash', as: :credit
  get 'money_requests/config', to: 'money_request#config_details'
  delete 'money_requests/destroy', to: 'money_request#destroy'
  resources :money_request, only: [:create, :index, :show, :destroy, :update]
  resources :money_request do
    post 'comment' => 'money_request#comment', as: :comment
  end


  ######################## SSO LOGIN START #############################
  post 'oauth/sso_login', to: 'sso/token#create', as: :create_sso
  ######################################################################

  # ############ Darwinbox SSO LOGIN APIs START #################################
  # post 'oauth/sso_login', to: 'darwinbox_sso/token#create', as: :darwinbox_create_sso
  # #############################################################################
  #
  # ############ Remunance SSO LOGIN APIs START #################################
  # # post 'remunance/oauth/sso_login', to: 'remunance_sso/token#create', as: :remunance_create_sso
  # get 'remunance/oauth/sso_login', to: 'remunance_sso/token#create', as: :remunance_create_sso
  # ##############################################################################

  ######################### TRAVEL REQUESTS API START ##########################

  get 'travel_requests/count', to: 'travel_requests#count'
  get 'travel_requests/config', to: 'travel_requests#configuration'
  resources :travel_requests do
    patch 'review', to: 'travel_requests#review', as: :review

    resources :destinations, controller: 'travel_request_destinations', only: [:create, :update, :destroy]
    resources :destinations do
      # resources :booking_requests, controller: 'travel_request_booking_requests', only: [:create, :update, :destroy]
      resources :bookings, controller: 'travel_request_bookings', only: [:create, :update, :destroy]
      resources :bookings do
        patch 'select_option', to: 'travel_request_bookings#select_option'
        patch 'unselect_option', to: 'travel_request_bookings#unselect_option'
        patch 'cancel', to: 'travel_request_bookings#cancel'
        patch 'mark_as_unavailable', to: 'travel_request_bookings#mark_as_unavailable'
        patch 'reject', to: 'travel_request_bookings#reject_booking_request'
      end
    end

    resources :comments, controller: 'travel_requests_comments', only: [:create]
  end
  post 'bookings/upload_attachment', to: 'bookings#upload_attachment'

  resources :booking_attachments, only: [:create]

  get 'booking_types', to: 'travel_requests#booking_types'

  ######################### TRAVEL REQUESTS API END ##########################

  post 'expenses/split', to: 'expenses#split_existing'
  post 'expenses/export', to: 'expenses#export'
  delete 'expenses', to: 'expenses#destroy'

  get 'expenses/edit_config', to: 'expenses#expense_edit_config'
  resources :expenses do
    post 'attach_receipt', to: 'expenses#attach_receipt'
    post 'detach_receipt', to: 'expenses#detach_receipt'
    post 'add_receipt', to: 'expenses#add_receipt'
    patch 'mark', to: 'expenses#mark', as: :mark
    patch 'unmark', to: 'expenses#unmark', as: :unmark
    get 'duplicates', to: 'expenses#duplicates'
  end

  post 'expenses/unreported', to: 'expenses#unreported', as: :expenses_unreported

  get 'receipts/export', to: 'receipts#export'
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

  get 'users/all_cards', to: 'users#all_cards', as: :all_cards
  resources :users, only: [:create, :update, :index, :destroy, :show]
  resources :users do
    get 'summary', to: 'users#summary', as: :user_summary
    post 'user_details', to: 'users#user_details', as: :details
    patch 'update_user_team', to: 'users#update_team', as: :update_team
    patch 'update_role', to: 'users#update_user_role', as: :update_role
    get 'profile', to: 'users#profile', as: :profile
    post 'update_password', to: 'users#update_password', as: :update_password
    post 'update_signature', to: 'users#update_signature', as: :update_signature
    get 'balance', to: 'users#balance', as: :balance
    get 'balances', to: 'users#balances', as: :balances
    get 'verify_reset_otp', to: 'users#verify_reset_password_otp', as: :verify_reset_password_otp
    patch 'set_delegate', to: 'users#set_delegate', as: :set_delegate
  end
  get 'company_users', to: 'users#company_users', as: :company_users
  get 'user_delegates', to: 'users#user_delegates', as: :user_delegates
  patch 'users/:id/set_delegates', to: 'users#set_delegates', as: :set_delegates
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

  get 'settlements/:id/summary' => 'settlements#user_summary'
  get 'settlements/summary' => 'settlements#summary'
  resources :settlements
  post 'settlements/:id/add_payment' => 'settlements#add_payment', as: :settlement_add_payment

  get 'expense_type_configurations', to: 'expense_types_configuration#show', as: :expense_type_configuration_show
  patch 'expense_type_configurations', to: 'expense_types_configuration#update', as: :expense_type_configuration_update
  get 'groups_teams', to: 'expense_types_configuration#groups_teams'
  get 'expense_filters', to: 'expense_types_configuration#expense_filters'
  get 'report_filters', to: 'expense_types_configuration#report_filters'

  get 'field_configurations', to: 'field_configuration#index'

  scope :settlements do
    scope :reports do
      get 'pending', to: 'settlement/report#pending_index'
      get 'pending/count', to: 'settlement/report#pending_count'
      scope :processing do
        get '/', to: 'settlement/report#processing_index'
        get 'count', to: 'settlement/report#processing_count'
        post 'init', to: 'settlement/report#processing_init'
        post 'create', to: 'settlement/report#processing_create'
        post 'cancel', to: 'settlement/report#processing_cancel'
        post 'mark_as_paid', to: 'settlement/report#processing_mark_paid'
        get 'payment_file', to: 'settlement/report#processing_payment_file'
      end
      get 'completed', to: 'settlement/report#completed_index'
      get 'completed/count', to: 'settlement/report#completed_count'
      get 'completed/batch', to: 'settlement/report#completed_batch_index'
      get 'completed/batch/count', to: 'settlement/report#completed_batch_count'
    end
    scope :money_requests do
      get 'pending', to: 'settlement/money_requests#pending_index'
      get 'pending/count', to: 'settlement/money_requests#pending_count'
      scope :processing do
        get '/', to: 'settlement/money_requests#processing_index'
        get 'count', to: 'settlement/money_requests#processing_count'
        post 'init', to: 'settlement/money_requests#processing_init'
        post 'create', to: 'settlement/money_requests#processing_create'
        post 'cancel', to: 'settlement/money_requests#processing_cancel'
        post 'mark_as_paid', to: 'settlement/money_requests#processing_mark_paid'
        get 'payment_file', to: 'settlement/money_requests#processing_payment_file'
      end
      get 'completed', to: 'settlement/money_requests#completed_index'
      get 'completed/count', to: 'settlement/money_requests#completed_count'
      get 'completed/batch', to: 'settlement/money_requests#completed_batch_index'
      get 'completed/batch/count', to: 'settlement/money_requests#completed_batch_count'
    end
  end

  resources :per_diems

  resources :card_transactions do

  end

  get 'atm_withdrawals', to: 'card_transactions#atm_withdrawals', as: :atm_withdrawals
  get 'refunds', to: 'card_transactions#refunds', as: :refunds

  get 'cancelled_against_transactions/:expense_id', to: 'card_transactions#cancelled_transactions', as: :cancelled_transactions

  get 'statements/company_balance_summary' => 'statements#company_balance_summary'
  get 'statements/company_transactions_summary' => 'statements#company_transactions_summary'
  get 'statements/company_policies_summary' => 'statements#company_policies_summary'

  get 'exports/:type', to: 'export#processor'

  get 'statements/user_summary' => 'statements#user_summary'
  get 'statements/user_summary/export' => 'statements#user_summary_export'
  post 'statements/user_summary' => 'statements#user_summary'
  post 'statements/user_summary/export' => 'statements#user_summary_export'
  #get 'statements/:id/summary' => 'statements#summary'
  get 'statements/summary' => 'statements#summary'
  get 'export/:id/statements(.:format)', to: 'export#statement', as: :export_statement
  resources :statements
  get 'statements/:id/export', to: 'statements#export'

  post 'custom_fields/:field_configuration_id/drop_down_items', to: 'custom_fields#dropdownitem_create'
  delete 'custom_fields/:field_configuration_id/drop_down_items/:drop_down_item_id', to: 'custom_fields#dropdownitem_destroy'
  resources :custom_fields, only: [:create, :index, :show, :update, :destroy]
  get 'custom_fields/:drop_down_id/dependent_custom_fields', to: 'custom_fields#dependent_custom_fields', as: :dependent_custom_fields

  # get 'settlements/summary' => 'settlements#summary'

  root 'home#index'
  get 'welcome' => 'home#welcome'

  get 'about', to: 'home#about'
  get 'resources', to: 'home#resources'

  get 'currencies', to: 'expenses#currencies'


  #Filters/Autocomplete
  get 'autocomplete/merchant'
  get 'autocomplete/user'
  get 'autocomplete/card', to: 'autocomplete#card'
  get 'autocomplete/inventory_items', to: 'autocomplete#inventory_items'

  get 'autocomplete/customers', to: 'invoicing/autocomplete#customer'
  get 'autocomplete/vendors', to: 'autocomplete#vendors'

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
  get 'menu_data_collect' => 'expense_types_configuration#menu_data_collect'
  get 'menu_data_insights' => 'expense_types_configuration#menu_data_insights'

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

  resources :locations

  resources :departments

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
  post 'disburse/users/import', to: 'disburse/users#import'

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

    patch 'agreements/agree' => 'agreements#agree', as: :agreements_agree
    resources :agreements
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
  patch 'quickbooks/sync_users', to: 'quickbooks#sync_users', as: :sync_users
  get 'quickbooks/config', to: 'quickbooks#show', as: :quickbooks_config

  namespace :integration do
    scope :tally do
      get 'check', to: 'tally#check'
      get 'vouchers', to: 'tally#vouchers'
      get 'reimbursements', to: 'tally#reimbursements'
      post 'configuration', to: 'tally#set_configuration'
    end

    scope :net_suite do
      get 'check', to: 'net_suite#check'
      get 'invoices', to: 'net_suite#invoices'
    end

  end


  get 'tos', to: 'static_pages#tos'
  get 'privacy', to: 'static_pages#privacy'
  get 'prepaid_card_agreement', to: 'static_pages#prepaid_card_agreement'
  get 'bank_transfer_agreement', to: 'static_pages#bank_transfer_agreement'


  # Bank Accounts
  resources :bank_accounts

  # ROUTES FOR VENDOR PAYMENTS
  resources :cost_centers
  resources :tds_slabs


  scope :payments do
    resources :companies do
      post 'add_balance', to: 'companies#add_balance', as: :add_balance_payments
    end
  end

  get 'payment_request_configs', to: 'bank_transfer/bank_payment_requests#index_configurations', as: :request_index_configs
  get 'payment_request_filters', to: 'bank_transfer/bank_payment_requests#index_configurations', as: :request_filters
  namespace :bank_transfer do
    get 'payment_orders/count', to: 'payment_orders#count'
    get 'payment_orders/balance', to: 'payment_orders#balance'
    resources :payment_orders do

    end
    get 'bank_payment_requests/count', to: 'bank_payment_requests#count', as: :count
    post 'payment_requests/process_file', to: 'bank_payment_requests#process_file'
    post 'payment_requests/account_details', to: 'bank_payment_requests#account_details'
    post 'payment_requests/process_account_ids', to: 'bank_payment_requests#process_account_ids'
    patch 'payment_requests/update_details', to: 'bank_payment_requests#update_details'
    get 'export/payment_file(.:format)', to: 'bank_payment_requests#payment_file', as: :export_payment_file
    post 'export/payment_file(.:format)', to: 'bank_payment_requests#payment_file', as: :export_payment_file_post
    patch 'mark_as_credited', to: 'bank_payment_requests#mark_as_credited', as: :mark_as_credited_bulk
    patch 'mark_all_pending', to: 'bank_payment_requests#mark_all_pending', as: :mark_all_pending
    patch 'bulk_approve_validate', to: 'bank_payment_requests#bulk_approve_validate', as: :bulk_approve_validate
    patch 'bulk_approve', to: 'bank_payment_requests#bulk_approve', as: :bulk_approve
    post 'download_selected', to: 'bank_payment_requests#download_selected', as: :download_selected
    get 'download_selected_attachment', to: 'bank_payment_requests#download_selected_attachment', as: :download_selected_attachment
    post 'download_pending', to: 'bank_payment_requests#download_pending', as: :download_pending
    get 'download_pending_attachment', to: 'bank_payment_requests#download_pending_attachment', as: :download_pending_attachment
    post 'download_all', to: 'bank_payment_requests#download_all', as: :download_all
    get 'download_all_attachment', to: 'bank_payment_requests#download_all_attachment', as: :download_all_attachment
    patch 'bulk_credit_validate', to: 'bank_payment_requests#bulk_credit_validate', as: :bulk_credit_validate
    patch 'bulk_credit', to: 'bank_payment_requests#bulk_credit', as: :bulk_credit
    get 'sample_import_format', to: 'bank_payment_requests#sample_import_file', as: :sample_import_file
    # patch 'bulk_credit_validate', to: 'bank_payment_requests#bulk_approve_validate', as: :bulk_credit_validate

    resources :bank_payment_requests do
      post 'comment', to: 'bank_payment_requests#comment', as: :comment
      patch 'review', to: 'bank_payment_requests#review', as: :review
      patch 'credit', to: 'bank_payment_requests#credit', as: :credit
      patch 'add_beneficiary', to: 'bank_payment_requests#add_beneficiary', as: :add_beneficiary
      patch 'add_invoice', to: 'bank_payment_requests#add_invoice', as: :add_invoice
      patch 'remove_beneficiary', to: 'bank_payment_requests#remove_beneficiary', as: :remove_beneficiary
      patch 'mark_as_credited', to: 'bank_payment_requests#mark_as_credited', as: :mark_as_credited
      patch 'retry', to: 'bank_payment_requests#retry', as: :retry
      get 'within_timeframe', to: 'bank_payment_requests#within_timeframe'
      patch 'update_payment', to: 'bank_payment_requests#update_payment'
      get 'payments', to: 'bank_payment_requests#payments_list', as: :payments_lst
      get 'payments_count', to: 'bank_payment_requests#payments_count'
      delete 'remove_attachment', to: 'bank_payment_requests#remove_attachment', as: :remove_attachment
    end

    get 'transfer_timings', to: 'bank_payment_requests#within_timeframe'

    get 'account_owners/search', to: 'account_owners#search', as: :search
    get 'account_owners/count', to: 'account_owners#count'
    resources :account_owners do
      get 'bank_accounts', to: 'account_owners#bank_accounts', as: :bank_accounts
    end

    post 'vendors/import', to: 'vendors#import', as: :import
    get 'vendors/new_vendor_config', to: 'vendors#new_vendor_config', as: :new_vendor_config
    resources :vendors do
      put 'upload_attachments', to: 'vendors#upload_attachments'
      put 'remove_attachment', to: 'vendors#remove_attachment'
      get 'show_transfers', to: 'vendors#show_transfers'
      get 'bank_accounts', to: 'vendors#bank_accounts'
    end

    get 'bank_accounts/count', to: 'bank_accounts#count'
    patch 'bank_accounts/disable', to: 'bank_accounts#disable', as: :bank_accounts_disable
    resources :bank_accounts

    post 'payments/bulk_upload_utr', to: 'payments#bulk_upload_utr', as: :bulk_upload_utr
    get 'payments/count', to: 'payments#count'
    get 'payments/payouts', to: 'payments#payout_index'
    resources :payments do
      patch 'retry', to: 'payments#retry', as: :retry
    end

    get 'users/count', to: 'users#count'
    get 'users/managers', to: 'users#get_managers'
    get 'users/categories', to: 'users#categories'

    resources :users do
      get 'show_transfers', to: 'users#show_transfers'
    end
    post 'vendor_payment_wallets/update_balance', to: 'vendor_payment_wallets#update_balance', as: :update_balance
    get 'vendor_payment_wallets/transfer_options/:id', to: 'vendor_payment_wallets#transfer_options', as: :transfer_options

    get 'inward_invoices/count', to: "inward_invoices#count", as: :invoice_count
    resources :inward_invoices do
      post 'create_payment', to: 'inward_invoices#create_payment', as: :create_payment
      get 'show_payments', to: 'inward_invoices#show_payments', as: :show_payments
    end

    resources :vendor_types

    resources :inward_invoices
  end


  get 'account/:account_number', to: 'invoicing/public_links#virtual_bank_account_show', as: :public_bank_account
  get 'invoice/:invoice_id', to: 'invoicing/public_links#invoice_show', as: :public_invoice

  resources :addresses

  namespace :invoicing do
    resources :payment_receivables
    get 'outward_invoices/count', to: 'outward_invoices#count'
    patch 'outward_invoices/send_to_customer', to: 'outward_invoices#send_to_customer', as: :send_to_customer
    resources :outward_invoices do
      patch 'add_customer', to: 'outward_invoices#add_customer', as: :add_customer
      patch 'remove_customer', to: 'outward_invoices#remove_customer', as: :remove_customer
      patch 'update_address', to: 'outward_invoices#update_address', as: :update_address
      patch 'update_virtual_account', to: 'outward_invoices#update_virtual_account', as: :update_virtual_account
      patch 'cancel', to: 'outward_invoices#cancel', as: :cancel
      patch 'save', to: 'outward_invoices#save', as: :save
      post 'upload_attachment', to: 'outward_invoices#upload_attachment', as: :upload_attachment
      get 'download_pdf', to: 'outward_invoices#download', as: :download
      patch 'mark_as_closed', to: 'outward_invoices#mark_as_closed', as: :mark_as_closed
      patch 'send_to_customer', to: 'outward_invoices#send_to_customer', as: :send_to_customer
      patch 'remind_customer', to: 'outward_invoices#remind_customer', as: :remind_customer
      patch 'record_payment', to: 'outward_invoices#record_payment', as: :record_payment
    end
    get 'customers/count', to: 'customers#count'
    post 'customers/import', to: 'customers#import'
    resources :customers do
      get 'virtual_accounts', to: 'customers#virtual_bank_accounts', as: :virtual_accounts
      post 'create_virtual_account', to: 'customers#create_virtual_account', as: :create_virtual_account
      get 'payments', to: 'customers#payments', as: :payments
      get 'invoices', to: 'customers#invoices', as: :invoices
      get 'payments/count', to: 'customers#payments_count', as: :payments_count
      get 'invoices/count', to: 'customers#invoices_count', as: :invoices_count
    end

    get 'virtual_bank_accounts/count', to: 'virtual_bank_accounts#count', as: 'virtual_bank_accounts_count'
    resources :virtual_bank_accounts do
      get 'transactions', to: 'virtual_bank_accounts#show_payments', as: :show_payments
    end

    resources :transactions, only: [:index]
    get 'transactions/count', to: 'transactions#count', as: :count

    get 'categories/invoice', to: 'categories#invoice_categories'
    get 'categories/invoice_line_items', to: 'categories#invoice_items_categories'

    resources :invoice_number_configs
    get 'company_configurations/auto_transfer_config', to: 'company_configurations#funds_auto_transfer_config'
    patch 'company_configurations/auto_transfer_config', to: 'company_configurations#update_auto_transfer_config'
    resources :company_configurations do
      patch 'update_credit_account', to: 'company_configurations#update_credit_account'
      patch 'update_collect_details', to: 'company_configurations#update_collect_details'
      patch 'update_collect_logo', to: 'company_configurations#update_collect_logo'
      get 'show_collect_detail', to: 'company_configurations#show_collect_details'
      get 'show_credit_account', to: 'company_configurations#show_credit_account'

      # resources :company_branches


    end
    get 'inventory_line_items/count', to: 'inventory_line_items#count', as: :inventory_line_items_count
    get 'inventory_item_config', to: 'inventory_line_items#inventory_item_config', as: :inventory_item_config
    put 'inventory_line_items/import', to: 'inventory_line_items#import', as: :inventory_line_items_import
    get 'inventory_line_items/import_template', to: 'inventory_line_items#import_template', as: :inventory_line_items_import_template
    resources :inventory_line_items
    resources :payment_terms
    resources :reminders
    patch 'companies/withdraw_funds', to: 'companies#withdraw_funds', as: :withdraw_funds
    get 'companies/show_credit_account', to: 'companies#show_credit_account', as: :show_credit_account
    get 'companies/transfer_history', to: 'companies#transfer_history', as: :transfer_history

    resources :analytics, only: [:index]
  end


  scope :admin do
    namespace :admin_users do
      resources :funds_load_requests do
        patch 'approve', to: 'funds_load_requests#approve'
        patch 'reject', to: 'funds_load_requests#reject'
      end
    end
  end


  namespace :summary do
    get 'configurations', to: 'configuration#index'
    post 'configurations/admin', to: 'configuration#admin_create'
    delete 'configurations/admin/:id', to: 'configuration#admin_destroy'
    post 'configurations/manager', to: 'configuration#manager_create'
    delete 'configurations/manager/:id', to: 'configuration#manager_destroy'
  end

  get 'ping', to: 'ping#ping'
  get 'ping/sidekiq/:type', to: 'ping#sidekiq'
  get 'ping/database', to: 'ping#database'

  ######## Budget apis start ######

  get 'budgets/sample_import_file', to: 'budgets#sample_import_file', as: :sample_import_file
  post 'budgets/import', to: 'budgets#import', as: :budget_import
  ## Budget apis start ##
  resources :budgets do
    patch 'add_budget', to: 'budgets#add_budget', as: :add_budget
    patch 'reduce_budget', to: 'budgets#reduce_budget', as: :reduce_budget
    get 'modification_trails', to: 'budgets#trails', as: :trails
  end
  get 'new_budget_config', to: 'budgets#new_budgets_config', as: :new_budgets_config

  ######## Budget apis end #########


  ## Procurement APIs start ##########################################
  namespace :procure do
    get 'procurements/filter_config', to: "procurements#filter_config"
    get 'procurements/count', to: 'procurements#count'
    resources :procurements do
    end


    put 'purchase_orders/bulk_approve', to: 'purchase_orders#bulk_approve'

    get 'purchase_orders/templates', to: 'purchase_orders#template_index'
    get 'purchase_orders/templates/:id', to: 'purchase_orders#template_show'
    # post 'purchase_orders/templates', to: 'purchase_orders#template_create'
    patch 'purchase_orders/templates/:id', to: 'purchase_orders#template_update'
    delete 'purchase_orders/templates/:id', to: 'purchase_orders#template_destroy'

    resources :purchase_orders do
      post 'send_mail', to: 'purchase_orders#send_mail'
      put 'submit', to: 'purchase_orders#submit'
      put 'retract', to: 'purchase_orders#retract'
      put 'approve', to: 'purchase_orders#approve'
      put 'reject', to: 'purchase_orders#reject'
      put 'close', to: 'purchase_orders#close'
      get 'download_pdf', to: 'purchase_orders#download', as: :download
      put 'remind', to: 'purchase_orders#remind'
      put 'void', to: 'purchase_orders#void'
      post 'save_as_template', to: 'purchase_orders#template_create'
      post 'apply_template', to: 'purchase_orders#template_apply'
      put 'make_advance_payment', to: 'purchase_orders#create_payment'
      get 'advance_payments', to: 'purchase_orders#advance_payments', as: :advance_payments
    end

    resources :inward_documents do

    end

    post 'payments/create_bulk_advance', to: 'payments#bulk_create_advance', as: :bulk_create_advance
    resources :payments, only: [:show]

    resources :attachments
    post 'inward_invoices/create_from_po', to: 'inward_invoices#create_from_po', as: :create_from_po



    get 'inward_invoices/templates', to: 'inward_invoices#template_index'
    get 'inward_invoices/templates/:id', to: 'inward_invoices#template_show'
    # post 'purchase_orders/templates', to: 'purchase_orders#template_create'
    patch 'inward_invoices/templates/:id', to: 'inward_invoices#template_update'
    delete 'inward_invoices/templates/:id', to: 'inward_invoices#template_destroy'

    get 'inward_invoices/import_template', to: 'inward_invoices#import_template'
    post '/inward_invoices/import', to: 'inward_invoices#import'

    put 'inward_invoices/bulk_approve', to: 'inward_invoices#bulk_approve'
    resources :inward_invoices do
      put 'submit', to: 'inward_invoices#submit'
      put 'retract', to: 'inward_invoices#retract'
      put 'approve', to: 'inward_invoices#approve'
      put 'reject', to: 'inward_invoices#reject'
      put 'close', to: 'inward_invoices#close'
      post 'save_as_template', to: 'inward_invoices#template_create'
      post 'apply_template', to: 'inward_invoices#template_apply'
    end

    resources :delivery_challans
    resources :e_way_bills
    resources :bill_of_supplies

    # Organization Account Settings for procurements
    namespace :configs do
      resources :terms
      resources :doc_number_configs, only: [:index, :update]
      post 'send_mail', to: 'mailer#send_mail'
    end

    resources :comments, only: [:create]
  end

  ## Procurement APIs end   ##########################################

  ######## Reviewal Workflow ##########
  resources :reviewal_levels do
    post 'reviewers', to: 'reviewers#create'
  end


  ######## Reviewal Workflow End ##########

  ### Audit Trails ##
  resources :audit_trails, only: [:index]
  ### Audit Trails End ##





  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".
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
