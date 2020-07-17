forms = @op["model.index"]


# json.forms forms

json.array!(forms) do |form|
  json.extract! form, :id, :updated_at
  json.document_name form.model.name
end

