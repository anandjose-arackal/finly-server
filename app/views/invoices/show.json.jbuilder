# json.data @op['contract.default'].to_form

json.form_data do
  json.id @op['model'].id
  json.merge! @op['model'].form_data(@op['form'])
end


json.reviewal_chain @op['model'].get_reviewal_chain