json.success true
json.data do
  json.manager_name @manager_name
  json.total @total
  json.report do
    json.partial! 'report', report: @report
  end
  json.buttons do
    json.take_control @views[:take_control]
    json.review @views[:review]
    json.unapprove @views[:unapprove]
    json.reimburse @views[:reimburse]
    json.add_expenses @views[:add_expenses]
    json.delete @views[:delete]
    json.retract @views[:retract]
    json.reimbursement_confirm @views[:reimbursement_confirm]
  end
  json.expenses_group @expenses do |expense|
    json.extract! expense, :category_name, :category_total
    json.expenses expense[:expenses] do |expense_item|
      json.partial! '/api/v1/expenses/expense', expense: expense_item
    end
  end
  json.comments @comments do |comment|
    json.extract! comment, :id, :user_id, :report_id, :report_comment_action_id
    json.content comment.generate
    json.user_name comment.user.name
  end
  json.policies @policies, :id, :name
  json.violations do

  end
end