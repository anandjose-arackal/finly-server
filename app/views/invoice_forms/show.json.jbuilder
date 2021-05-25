json.form_data do
  json.id @op['model'].id
  json.merge! @op['model'].form_data(@op['form'])
end

json.meta @op['model'].form_metadata

# Additional Data
json.created_by @op['model']&.created_by.as_json

json.reviewal_chain @op['model'].get_reviewal_chain

json.transfer_modes @op['model']&.created_by&.company&.transfer_modes.as_json

json.bank_payment_request_policies @op['model']&.bank_payment_request_policies(current_user)