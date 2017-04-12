json.extract! @result.selected_user, :first_name, :last_name, :mobile_number, :email, :address_1, :address_2, :pin_code, :city, :state_id,
                                     :gender, :company_name, :id, :mothers_maiden_name
json.date_of_birth @result.selected_user.date_of_birth.strftime("%d-%m-%Y")
