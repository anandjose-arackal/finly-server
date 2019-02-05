# json.departments do
#   json.array!(@result.departments.roots) do |department|
#     json.id department.id
#     json.name department.name
#     if department.children.present?
#       json.sub_categories do
#         json.array!(department.children.active) do |sub_category|
#           json.id sub_category.id
#           json.name sub_category.name
#         end
#       end
#     end
#   end
# end

# json.show_sync_button (current_company.quickbooks_configuration.present?)

json.departments do
  json.array!(@result.departments.roots) do |department|
    json.id department.id
    json.name department.name
    if department.children.present?
      json.sub_departments do
        json.array!(department.children) do |sub_department|
          json.id sub_department.id
          json.name sub_department.name
        end
      end
    end
  end
end