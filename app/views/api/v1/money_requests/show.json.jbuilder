json.partial! 'money_request', money_request: @result.money_request
json.manager_name @result.manager.present? ? @result.manager.name : ''
json.finance_manager_name @result.finance_manager.present? ? @result.finance_manager.name : ''
json.actions do
  @result.actions.each do |key, value|
    v = value
    unless value == true or value == false
      v = value.present?
    end
    json.set! key, v
  end
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

json.forwardable_users do
  forwardable_users = @result.forwardable_users
  if forwardable_users.present?
    json.array! forwardable_users.each do |item|
      json.user do
        user = item[:approver]
        json.id user.id
        json.name user.name
        json.email user.email
      end
      json.user_role do
        json.id item[:role_id]
        json.name UserRole.name_for(item[:role_id]).to_s.humanize
      end
      json.position item[:pos]
      json.is_reviewer item[:reviewer]
    end
  end
end

json.payment_modes do
  json.array! PaymentMode.all.each do |item|
    json.id item.id
    json.name item.name
  end
end
json.custom_fields do
  json.array! @result.money_request.custom_fields
end