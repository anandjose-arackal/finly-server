json.merge! @result.inventory_item.as_json
json.artifacts_attributes do
  if @result.inventory_item.artifacts.present?
    json.array!(@result.inventory_item.artifacts) do |artifact|
      json.uid artifact.id
      json.name artifact&.attachment_file_name
      json.url artifact&.attachment&.url
      json.status 'done'
    end
  else
    []
  end
end