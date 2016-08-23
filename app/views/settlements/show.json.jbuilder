json.array!(@reports) do |report|
  # debugger
  json.extract! report[:report], :id, :name, :report_status_id
  json.reimbursement_amount report[:reimbursement_amount]
  json.total_amount report[:total_amount]
  json.final_approver report[:final_approver]
  # json.name report[:report].name
end