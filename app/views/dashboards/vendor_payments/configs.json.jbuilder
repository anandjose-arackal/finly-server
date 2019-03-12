json.departments do
  json.array! @result.departments do |department|
    json.extract! department, :id, :name
  end
end

json.request_types @result.request_types