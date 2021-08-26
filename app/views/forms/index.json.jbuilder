forms = @op["model.index"]
# json.forms forms
json.result do
  json.array!(forms) do |form|
    # model_name = form.model.name == 'YesBankVendor' ? 'Vendor' : form.model.name

    model_name = form.model.name
    if form.model.name == 'YesBankVendor'
      model_name = 'Vendor' 
    elsif form.model.name == 'Invoice'
      model_name = 'Invoice'
    end 
      

    json.extract! form, :id, :updated_at
    json.document_name model_name
  end
end


