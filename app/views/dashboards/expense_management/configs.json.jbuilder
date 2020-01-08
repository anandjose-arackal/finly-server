json.departments do
  json.array! @result.departments do |department|
    # json.extract! department, :id, :name
    json.merge! department.as_json(tree: true)
  end
end

json.sub_departments do
  json.array! @result.sub_departments do |department|
    # json.extract! department, :id, :name
    json.merge! department.as_json(tree: true)
  end
end

json.policies do
  json.array! @result.policies do |policy|
    json.extract! policy, :id, :name
  end
end

json.locations do
  json.array! @result.locations do |location|
    # json.extract! location, :id, :name
    json.merge! location.as_json(tree: true)
  end
end

json.request_types @result.request_types