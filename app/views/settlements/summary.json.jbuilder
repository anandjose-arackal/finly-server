json.pending_reimbursement @result.user.balance_sheet.pending_reimbursement.value
json.cash_in_hand @result.user.balance_sheet.cash_in_hand.value

# json.actions do
#   @result.actions.each do |key, value|
#     json.set! key, value[:url]
#   end
# end

json.actions do
  @result.actions.each do |key, value|
  # b.actions.each do |key, value|
    json.set! key, (value[:url] or value[:value])
    # puts key, (value[:url] or value[:value])
  end
end