json.extract! @result.selected_user, :first_name, :last_name, :mobile_number, :email, :address_1, :address_2, :pin_code, :city, :state_name,
                                     :company_name, :id, :mothers_maiden_name, :active
json.date_of_birth @result.selected_user.date_of_birth.strftime("%d-%m-%Y")
json.gender @result.selected_user.gender_name

json.cards do
  json.expense_card do
    @result.cards.expense_cards_only.each do |card|
      json.proxy card.proxy
      json.id card.id
      json.ending_number card.ending_number
      json.active card.active
    end
  end
  json.reimbursement_card do
    @result.cards.reimbursement_cards_only.each do |card|
      json.proxy card.proxy
      json.id card.id
      json.ending_number card.ending_number
      json.active card.active
    end
  end
end