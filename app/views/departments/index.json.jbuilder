json.array!(@result.departments) do |department|
  json.extract! department, :name
end