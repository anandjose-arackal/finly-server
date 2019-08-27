json.departments @result.departments.roots&.map(&:json_tree)

# used in vp organization account
json.all_departments @result.all_departments&.map(&:json_tree)