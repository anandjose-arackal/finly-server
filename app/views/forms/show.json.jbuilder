form = @op["model"]

json.result do
  form.sections.each do |section|
    json.set! section.section_id, section.as_json(params: @op[:params], current_user: @op[:current_user]).merge(id: section.id)
  end
end
