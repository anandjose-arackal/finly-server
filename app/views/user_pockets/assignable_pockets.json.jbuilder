json.array!(@result.pocket_templates) do |pocket_template|
  json.id pocket_template
  json.name pocket_template.name
end