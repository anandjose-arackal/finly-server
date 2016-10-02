json.extract! @result.money_request, :id, :name, :memo, :status_name, :status_id
required_by_date = @result.money_request.required_by_date.strftime("%d %b %y") rescue nil
json.required_by_date required_by_date
json.user_name @result.money_request.user.name
json.user_initial @result.money_request.user.name.split(' ').first[0] + ((@result.money_request.user.name.split(' ')[1][0] rescue nil) || @result.money_request.user.name.split(' ').first[1])
json.status @result.status
json.manager_name @result.manager.name rescue nil
json.finance_manager_name @result.finance_manager.name rescue nil
# json.export_csv export_money_request_path(money_request_id: @result.money_request.id, view: params[:view],:format => :csv)
# json.export_xls export_money_request_path(money_request_id: @result.money_request.id, view: params[:view],:format => :xls)
# json.export_pdf export_money_request_path(money_request_id: @result.money_request.id, view: params[:view],:format => :pdf)
json.export_csv ''
json.export_xls ''
json.export_pdf ''

# if @result.money_request.policy
policy_name = ''
policy_id = ''
if @result.money_request.policy
  policy_name = @result.money_request.policy.name
  policy_id = @result.money_request.policy.id
end
json.policy policy_name
json.policy_id policy_id
# end

json.policies @result.money_request.user.policies do |policy|
  json.extract! policy, :id, :name
end

json.total @result.money_request.total_amount
json.date @result.money_request.created_at.strftime("%d %b")

json.comments @result.comments do |comment|
  json.content comment.generate @result.user
  json.created_at comment.created_at.strftime("%d %b %y")
  if comment.user.respond_to?(:id, :name)
    json.comment_user_id comment.user.id
    json.comment_user_name comment.user.name
    json.comment_user_initial comment.user.name.split(' ').first[0] + ((comment.user.name.split(' ')[1][0] rescue nil) || comment.user.name.split(' ').first[1])
  end
end

json.request_items @result.items do |item|
  json.category do
    json.name item.category.name
    json.id item.category.id
  end
  json.amount do
    json.value item.amount.value
    json.currency do
      json.id item.amount.currency.id
    end
  end
end

json.actions do
  json.dummy 'dummy'
  @result.actions.each do |key, value|
    json.set! key, (value[:url] or value[:value])
  end
end