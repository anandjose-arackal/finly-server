json.headers @op[:data][:headers] if @op[:data].present?
json.data @op[:data][:choices] if @op[:data].present?