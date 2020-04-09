if @result.created_user.present?
  profile = @result.created_user.profile
  json.user do
    json.id @result.created_user.id
    json.first_name @result.created_user.first_name
    json.last_name @result.created_user.last_name
    json.email @result.created_user.email
    json.mobile_number @result.created_user.mobile_number

    json.date_of_birth profile.date_of_birth&.strftime("%d-%m-%y")
    json.gender profile.gender
    json.city profile.city
    json.pin_code profile.pin_code
    json.address_1 profile.address_1
    json.address_2 profile.address_2
    json.employee_id profile.employee_id
    json.payroll_id profile.payroll_id
  end
end