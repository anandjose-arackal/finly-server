json.form_data do
  json.id @op['model'].id
  json.merge! @op['model'].form_data(@op['form'])
  json.procurement_term_id @op['model'].procurement_term_id
  json.procurement_term_text @op['model'].procurement_term_text
end

json.meta @op['model'].form_metadata

# Additional Data
json.created_by @op['model']&.created_by.as_json

json.reviewal_chain @op['model'].get_reviewal_chain
json.transfer_modes @op['model']&.created_by&.company&.transfer_modes.as_json
json.budgets @op['model']&.purchase_order_budgets.as_json

# json.bank_payment_request_policies do
#   json.array! @op['model']&.bank_payment_request_policies(current_user) do |policy|
#     json.extract! policy, :id, :name
#   end
# end