forms = @op["model.index"]
# json.forms forms
json.result do
  json.array!(forms) do |form|
    model_name = form.model.name == 'YesBankVendor' ? 'Vendor' : form.model.name
    json.extract! form, :id, :updated_at
    json.document_name model_name
  end
end


