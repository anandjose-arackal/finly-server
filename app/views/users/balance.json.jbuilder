json.merge! @result.balances
allow_card_transfer = false
if @result.selected_user.cards.present?
  allow_card_transfer = @result.selected_user.cards.first.active
end
json.allow_card_transfer allow_card_transfer