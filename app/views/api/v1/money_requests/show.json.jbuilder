json.partial! 'money_request', money_request: @result.money_request
json.manager_name @result.manager.name rescue nil
json.finance_manager_name @result.finance_manager.name rescue nil
json.total do
  json.value @result.total
  json.currency do
    json.extract! Currency.first, :id, :country, :country_code, :symbol
  end
end
json.actions do
  json.take_control @result.actions[:take_control].present?
  json.review @result.actions[:approve].present?
  json.unapprove @result.actions[:unapprove].present?
  json.reimburse @result.actions[:reimburse].present?
  json.add_expenses @result.actions[:add_expenses].present?
  json.delete @result.actions[:delete].present?
  json.retract @result.actions[:retract].present?
  json.reimbursement_confirm @result.actions[:reimbursement_confirm].present?
  json.editable @result.actions[:editable].present?
  json.submit @result.actions[:submit].present?
end
json.categories @result.items.each do |item|
  json.category do
    json.id item.category.id
    json.name item.category.name
  end
  json.amount do
    json.value item.amount.value
    json.currency do
      json.extract! Currency.first, :id, :country, :country_code, :symbol
    end
  end
end
json.comments @result.comments do |comment|
  json.extract! comment, :id, :user_id, :money_request_id, :comment_action_id, :created_at
  json.content comment.generate
  json.user_name comment.user.name rescue nil
end
json.policies @result.policies, :id, :name