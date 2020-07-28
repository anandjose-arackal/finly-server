model = @op['model']
json.set! :result, model.as_json(config_path: "#{model.section.section_id}/entities")
