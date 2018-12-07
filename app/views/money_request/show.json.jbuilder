json.extract! @result.money_request, :id, :name, :memo, :status_id, :payment_mode_id
required_by_date = @result.money_request.required_by_date.strftime("%d %b %Y") rescue nil
json.required_by_date required_by_date
json.user_name @result.money_request.user.name
json.user_id @result.money_request.user.id
json.user_initial @result.money_request.user.name.split(' ').first[0] + ((@result.money_request.user.name.split(' ')[1][0] rescue nil) || @result.money_request.user.name.split(' ').first[1])
json.controlling_user @result.money_request.controlling_user
json.status @result.status_name(@result.money_request)
json.status_name @result.status_name(@result.money_request)
manager_name = @result.manager.name rescue ''
json.manager_name manager_name
json.controlling_user @result.money_request.controlling_user&.name
finance_manager_name = @result.finance_manager.name rescue ''
json.finance_manager_name finance_manager_name
json.export_csv ''
json.export_xls ''
json.export_pdf ''
json.enforce_policy_enabled @result.money_request.user.enforce_policy_enabled?
if @result.money_request.destination_pocket.present?
  json.destination_pocket do
    pocket = @result.money_request.destination_pocket
    json.id pocket.id
    json.name pocket.name
    json.pocket_type do
      json.id pocket.user_pocket_type.id
      json.name pocket.user_pocket_type.name
    end
    adapter = AccountManager::CashPockets::CashPocketsAdapter.new(pocket)
    json.balance adapter.balance(display_balance: true)
    currency = pocket.base_currency
    json.base_currency do
      json.symbol currency&.symbol
      json.country_code currency&.country_code
      json.id currency&.id
    end
  end
end

json.travel_request_enabled (current_company.feature_subscription.travel_request && current_user.user_panel_subscription.travel_request)
json.card @result.card

json.user_travel_requests @result.money_request.user.travel_requests.money_requestable

json.cash_pockets do
  json.array!(@result.cash_pockets) do |pocket|
    adapter = AccountManager::CashPockets::CashPocketsAdapter.new(pocket)
    json.name pocket.name
    json.balance adapter.balance(display_balance: true)
    json.id pocket.id
    json.base_currency do
      json.symbol pocket.base_currency&.symbol
      json.country_code pocket.base_currency&.country_code
      json.id pocket.base_currency&.id
    end
  end
end
travel_desk_enabled = @result.money_request.user.travel_desk_enabled?
json.show_trips travel_desk_enabled
if travel_desk_enabled
  json.pending_travel_requests @result.money_request.user.travel_requests, :id, :name
  json.associated_trip @result.money_request.travel_request
end

json.forwardable_users do
  forwardable_users = @result.forwardable_users
  if forwardable_users.present?
    json.array! forwardable_users.each do |item|
      json.user do
        user = item[:approver]
        json.id user.id
        json.name user.name
        expenses = []
        json.email user.email
      end
      json.user_role do
        json.id item[:role_id]
        json.name UserRole.name_for(item[:role_id])&.to_s&.humanize
      end
      json.position item[:pos]
      json.is_reviewer item[:reviewer]
    end
  end
end
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

json.policies @result.policies do |policy|
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

json.actions @result.actions

json.custom_fields do
  json.array! @result.money_request.custom_fields
end

# this will contain a summary of the user's account details
json.account_details do
  card = @result.money_request.user.cards.first
  cash_on_hand_pocket = @result.money_request.user.user_pockets.cash_pockets_only.first
  cash_on_hand_adapter = AccountManager::CashPockets::CashPocketsAdapter.new(cash_on_hand_pocket)
  finly_money_adapter = AccountManager::Wallet::WalletAdapter.new(@result.money_request.user.wallet)
  card_adapter = AccountManager::Cards::CardAdapter.new(card) if card.present?

  json.cash_on_hand_balance cash_on_hand_adapter.balance(display_balance: true)
  if card.present?
    json.card_balance card_adapter.balance
    json.card_type "#{card.card_program&.name&.humanize} Card"
  end
  json.finly_money_balance finly_money_adapter.balance
end