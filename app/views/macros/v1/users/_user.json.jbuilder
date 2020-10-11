profile = record.profile
json.extract! record, :id, :first_name, :last_name, :mobile_number, :email, :mothers_maiden_name, :created_at, :updated_at, :last_activity_at
json.cost_center record.cost_center
json.location record.location
json.department record.department
json.employee_id profile&.employee_id
json.date_of_birth profile&.date_of_birth
json.gender profile&.gender
json.address "#{profile&.address_1},#{profile&.address_2}"
json.city profile&.city