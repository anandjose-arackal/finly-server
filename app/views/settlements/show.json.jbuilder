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

json.array!(@result.send(@view_to_load)) do |report|
  json.merge! report.attributes 
end