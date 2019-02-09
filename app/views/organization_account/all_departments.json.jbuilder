json.departments do
  json.array!(@result.departments.roots) do |department|
    json.id department.id
    json.name department.name
  end
end