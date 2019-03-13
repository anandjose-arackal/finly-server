json.success true
json.otp_verified !@require_otp_verification
json.kyc_required @user.company.kyc_required?
# if @require_otp_verification
#   json.data do
#     json.user do
#       json.extract! @user, :id, :email, :obfuscated_mobile_number
#     end
#   end
# else
  json.data do
    json.access_token @token.token
    # json.token_type 'bearer'
    # json.refresh_token @token.refresh_token
    # json.expires_in @token.expires_in
    json.user do
      json.extract! @user, :id, :name, :email, :mobile_number
      json.roles @user.user_roles, :id, :name
    end
    json.company do
      json.id @user.company.id
      json.name @user.company.name
      json.d_code_assigned @user.company.d_code_enabled?
    end

    views = YamlUtils.load_yaml_erb("#{Rails.root}/config/data/feature_subscription.yml.erb", {current_company: @user.company, current_user: @user})
    json.feature_subscription do
      json.company do
        json.name views["company"]["name"]
        json.id views["company"]["id"]
        json.features do
          json.expense_management views["company"]["features"]["expense_management"]
          json.expense_card views["company"]["features"]["expense_card"]
          json.reimbursement_card views["company"]["features"]["reimbursement_card"]
          json.medical_card views["company"]["features"]["medical_card"]
          json.meal_card views["company"]["features"]["meal_card"]
        end
      end
      json.user do
        json.expense_management @user.user_panel_subscription.expense_management
        json.disburse @user.user_panel_subscription.disburse
        json.payments @user.user_panel_subscription.yes_bank_account_transfer
        json.collect @user.user_panel_subscription.invoicing_system
      end
    end
  end
# end