form = @op["model"]
final_params = @op[:params].merge({paginate: true})

json.result do
  form.sections.each do |section|
    json.set! section.section_id, section.as_json(params: final_params, current_user: @op[:created_by])
  end
end
