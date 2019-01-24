json.company do
  json.name current_company.name
  json.id current_company.id
  json.logo do
    if current_company.configuration.logo.present?
      json.url current_company.configuration.logo.url(:thumb)
    end
  end
  # json.features do
  #   json.expense_card current_company.feature_subscription.expense_card_enabled && current_user.user_panel_subscription.disburse
  #   json.meal_card current_company.feature_subscription.meal_card_enabled && current_user.user_panel_subscription.disburse
  #   json.medical_card current_company.feature_subscription.medical_card_enabled && current_user.user_panel_subscription.disburse
  #   json.reimbursement_card current_company.feature_subscription.reimbursement_card_enabled && current_user.user_panel_subscription.disburse
  #   json.expense_management current_company.feature_subscription.expense_management_enabled && current_user.user_panel_subscription.expense_management
  #   json.invoicing_system current_company.feature_subscription.invoicing_system && current_user.user_panel_subscription.invoicing_system
  #   json.insights current_company.feature_subscription.budgeting_system && current_user.vendor_payments_admin?
  # end
end
json.user do
  json.name current_user.name
  json.initials current_user.initials
  json.id current_user.id
  json.email current_user.email
  json.mobile_number current_user.mobile_number
end
json.config @result.config_data