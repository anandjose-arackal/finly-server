form = @op["model"]
form.sections.each do |section|
  json.set! section.section_id do
    json.section_id section.section_id
    json.title section.title
    json.entities do
      section.entities.exclude_internal.root.each do |entity|
        json.set! entity.field_path, entity.as_json({params: @op[:params], current_user: @op[:current_user]})
      end
    end
  end
end