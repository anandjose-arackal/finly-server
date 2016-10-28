json.merge! @result.balances
if @result.target_user.present?
  target_user_card_active = false
  if @result.target_user.cards.present?
    target_user_card_active = @result.target_user.cards.first.active
  end
  json.target_user_card_active target_user_card_active
end
if @result.user.present?
  current_user_card_active = false
  if @result.user.cards.present?
    current_user_card_active = @result.user.cards.first.active
  end
  json.current_user_card_active current_user_card_active
end