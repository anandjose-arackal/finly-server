json.categories do
  json.array!(@result.categories) do |category|
    json.id category.id
    json.name category.name
  end
end

json.show_sync_button (@result.company.quickbooks_configuration.present?)