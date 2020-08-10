entity = @op['model']

json.result do
  json.merge! entity.as_json(json_format: 'form_builder', current_user: @op[:current_user], params: @op[:params])
end


  # json.conditions do
  #   entity.conditions.as_json
  # end
  #
  # json.validations do
  #   entity.validations.as_json
  # end
  # end
