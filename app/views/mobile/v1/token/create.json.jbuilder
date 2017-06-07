json.success true
json.otp_verified @auth_grant.user.otp_verified
json.data do
  json.access_token @auth_grant.access_token
  json.token_type Opro.token_type || 'bearer'
  json.refresh_token @auth_grant.refresh_token
  json.expires_in @auth_grant.expires_in
  json.user do
    json.extract! @auth_grant.user, :id, :name, :email, :mobile_number
    json.roles @auth_grant.user.user_roles, :id, :name
  end
  json.company do
    json.id @auth_grant.user.company.id
    json.name @auth_grant.user.company.name
    json.d_code_assigned @auth_grant.user.company.d_code_assigned?
  end
  # debugger
  views = YamlUtils.load_yaml_erb("#{Rails.root}/config/data/feature_subscription.yml.erb", {current_company: @auth_grant.user.company, current_user: @auth_grant.user})
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
  end
end