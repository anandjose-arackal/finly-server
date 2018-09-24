json.extract! @result.department, :id, :name

if @result.parent_department.present?
  json.parent_department do
    json.extract! @result.parent_department, :id, :name
  end
end

json.sub_departments do
  json.array! @result.sub_departments do |department|
    json.extract! department, :id, :name
  end
end

json.users do
  json.array! @result.users do |user|
    json.merge! user.as_json
  end
end

json.actions @result.actions