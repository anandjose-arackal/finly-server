json.array!(@result.paginated_users) do |user|
  profile = user.profile
  bank_account = user.bank_accounts.default_accounts.first
  json.extract! expense, :id, :first_name, :last_name,:mobile_number, :email, :mothers_maiden_name, :created_at
  json.cost_center user.cost_center&.name
  json.cost_center_code user.cost_center&.cost_center_code
  json.location user.location&.name
  json.location_code user.location&.location_code
  json.department user.department&.name
  json.department_code user.department&.department_code
  json.employee_id profile&.employee_id
  json.date_of_birth profile&.date_of_birth
  json.gender profile&.gender
  json.address "#{profile&.address_1} #{profile&.address_2}"
  json.city profile&.city
  json.bank_account_name bank_account&.name
  json.bank_account_number bank_account&.account_number
  json.bank_account_ifsc bank_account&.ifsc
end