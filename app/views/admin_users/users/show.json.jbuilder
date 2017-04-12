json.extract! @result.selected_user, :first_name, :last_name, :mobile_number, :email, :address_1, :address_2, :pin_code, :city, :state_name,
                                     :company_name, :id, :mothers_maiden_name, :active
json.date_of_birth @result.selected_user.date_of_birth.strftime("%d-%m-%Y")
json.gender @result.selected_user.gender_name

json.cards do
  json.array!(@result.cards) do |card|
    json.type card.card_program_name
    json.proxy card.proxy
    json.ending_number card.ending_number
    json.active card.active
    json.id card.id
  end
end