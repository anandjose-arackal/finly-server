# json.array!(@reports) do |report|
#   # debugger
#   json.extract! report[:report], :id, :name, :report_status_id
#   json.reimbursement_amount report[:reimbursement_amount]
#   json.total_amount report[:total_amount]
#   json.final_approver report[:final_approver]
#   # json.name report[:report].name
#   # json.pending_reimbursement current_user.balance_sheet.pending_reimbursement.value
#   # json.cash_in_hand current_user.balance_sheet.cash_in_hand.value
# end

json.array! @result.items do |item|
  json.merge! item.attributes

  json.total_amount item.total_amount
  if item.is_a?(Report)
    json.amount item.reimbursement_amount.value
  elsif item.is_a?(Payment)
    json.amount item.amount.value
  end

#   json.merge! report.attributes
#   # json.total_amount 10
#   json.total_amount report.total_amount
  # json.final_approver report[:final_approver]
#   # ap report
end