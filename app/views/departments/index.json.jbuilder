json.array!(@result.departments) do |department|
  json.extract! department, :id, :name
  json.sub_departments do
    json.array! department.children do |sub_department|
      json.extract! sub_department, :id, :name
    end
  end
end

json.nested_company_departments @result.departments.arrange_serializable(order: :name)