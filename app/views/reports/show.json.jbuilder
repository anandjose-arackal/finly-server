json.extract! @result.report, :id, :name, :memo, :report_status_id, :auto_submit
json.user_name @result.report.user.name
json.user_initial @result.report.user.name.split(' ').first[0] + ((@result.report.user.name.split(' ')[1][0] rescue nil) or @result.report.user.name.split(' ').first[1])
json.status @result.status_name(@result.report)
json.status_name @result.status_name(@result.report)
json.controlling_user @result.report.controlling_user
manager = (@result.manager.name rescue '')
json.manager_name manager
finance_manager = (@result.finance_manager.name rescue '')
json.finance_manager_name finance_manager
json.export_csv export_report_path(report_id: @result.report.id, view: params[:view], :format => :csv)
json.export_xls export_report_path(report_id: @result.report.id, view: params[:view], :format => :xls)
json.export_pdf export_report_path(report_id: @result.report.id, view: params[:view], :format => :pdf)
json.enforce_policy_enabled @result.report.user.enforce_policy_enabled?
json.deleted @result.report.is_deleted
json.non_reimbursable_expenses_total @result.non_reimbursable_expenses_total
json.reimbursable_expenses_total @result.reimbursable_expenses_total
json.card_expenses_total @result.card_expenses_total
json.currency_symbol @result.report.base_currency_symbol
json.currency_country_code @result.report.base_currency_code
json.synced_with_quickbooks !!@result.report.synced_with_quickbooks?
json.show_sync_button (@result.report.processed? && is_admin_view)
json.controlling_user @result.report.controlling_user&.name

json.travel_request_enabled (current_company.feature_subscription.travel_request && current_user.user_panel_subscription.travel_request)

policy_id = nil
policy_name = nil
if @result.report.policy
  policy_id = @result.report.policy_id
  policy_name = @result.report.policy.name
  json.policy @result.report.policy.name
  json.policy_id @result.report.policy_id
end
json.policy policy_name
json.policy_id policy_id

json.policies @result.policies do |policy|
  json.extract! policy, :id, :name
end

json.total @result.report.total_amount
json.base_currency_id @result.report.base_currency_id
json.date @result.report.created_at.strftime('%d %b %Y')

json.approvers @result.approvers

json.comments @result.comments do |comment|
  json.content comment.generate @result.user
  json.created_at comment.created_at.strftime('%d %b %Y')
  comment_u_id = nil
  comment_u_name = 'System'
  comment_initials = 'S'
  if comment.user.respond_to?(:id, :name)
    comment_u_id = comment.user.id
    comment_u_name = comment.user.name
    comment_initials = comment.user.initials
  end
  json.comment_user_id comment_u_id
  json.comment_user_name comment_u_name
  json.comment_user_initial comment_initials
end

expenses_sorted_by = params[:expenses_sorted_by] || 'category'
json.expenses_sorted_by expenses_sorted_by
if expenses_sorted_by == 'category'
  sorted_expenses = @result.expenses_category_sorted
elsif expenses_sorted_by == 'date'
  sorted_expenses = @result.expenses_date_sorted
else
  sorted_expenses = @result.expenses_category_sorted
end

json.has_custom_fields @result.has_custom_fields?
json.expense_sections sorted_expenses do |category|
  json.extract! category, :section_name, :section_total
  json.expenses category[:expenses] do |expense|
    json.extract! expense, :id, :merchant_name, :amount_value, :expense_type_id,
                  :distance_value, :distance_rate_value, :time_value, :time_rate_value,
                  :expense_tax_type, :gst_percentage, :tds_percentage, :reimbursable_amount, :usage_date_type#, :usage_date_start, :usage_date_end
    json.usage_date_start DateUtils.date_formatted expense.usage_date_start
    json.usage_date_end DateUtils.date_formatted expense.usage_date_end
    if expense.category.parent.present?
      json.category_name expense.category.parent.name
      json.sub_category expense.category.name
    else
      json.category_name expense.category.name
    end
    if expense.note
      if expense.note.length < 29
        json.note expense.note
      else
        json.note expense.note[0..29] + '...'
      end
    end
    # json.extract! expense, :id, :note
    json.date expense.date.strftime('%d %b %y')
    json.reimbursable expense.reimbursable
    json.from_cash_on_hand expense.from_cash_on_hand
    json.spent_from_name expense.spent_from&.name
    json.synced_with_quickbooks expense.synced_with_quickbooks
    json.violations do
      items = @result.violations[expense.id]
      json.blocking_present (items[:expense_blocking].present? or items[:budget_blocking].present? or items['expense_blocking'].present? or items['budget_blocking'].present?)
      json.warning_present (items[:expense_warning].present? or items[:budget_warning].present? or items['expense_warning'].present? or items['budget_warning'].present?)
      json.items items
    end
    if expense.distance_expense?
      json.locations expense.distance_expense.locations, :name, :address, :latitude, :longitude, :order, :maps_id
    end
    json.potential_duplicate expense.has_duplicate_expenses?
    json.custom_fields do
      case expense.expense_type_id
      when ExpenseType.id_for(:manual)
        json.array! expense.manual_expense.custom_fields
      when ExpenseType.id_for(:card)
        json.array! expense.card_expense.custom_fields
      when ExpenseType.id_for(:distance)
        json.array! expense.distance_expense.custom_fields
      when ExpenseType.id_for(:time)
        json.array! expense.time_expense.custom_fields
      when ExpenseType.id_for(:per_diem)
        json.array! expense.per_diem_expense.custom_fields
      end
    end
    json.receipts do
      json.array! expense.receipts do |receipt|
        json.id receipt.id
        json.hard_copy_received receipt.hard_copy_received
        json.image do
          json.file_type receipt.file_format
          json.original receipt.image.url
          json.thumb receipt.image.url(:thumb)
        end
      end
    end

    json.tds_slab do
      json.id expense.tds_slab&.id
      json.tds expense.tds_slab&.tds
    end

    # adding pocket information for an expense
    if expense.spent_from.present?
      json.pocket do
        json.pocket_name expense.spent_from&.name
        json.pocket_id expense.spent_from&.id
        json.pocket_balance expense.spent_from&.name
      end
    end
  end
end

json.receipts @result.expenses do |expense|
  unless expense.receipts.blank? or expense.receipts.first.image.url == '/assets/original/missing.png'
    json.id expense.receipts.first.id
    json.hard_copy_received expense.receipts.first.hard_copy_received
    json.image do
      json.file_type expense.receipts.first.file_format
      json.original expense.receipts.first.image.url
      json.thumb expense.receipts.first.image.url(:thumb)
    end
    # json.url expense.receipts.first.image.url
    # json.file_type expense.receipts.first.file_format
    json.date expense.date.strftime('%d %b %Y')
    json.merchant_name expense.merchant_name
    json.amount_value expense.amount_value
  end
end

json.actions do
  json.dummy 'dummy'
  @result.actions.each do |key, value|
    json.set! key, (value[:url] or value[:value])
  end
end

json.violations do
  json.blocking_present @result.has_blocking?
  json.warning_present @result.has_warning?
  json.blocking_messages @result.blocking_array
  json.warning_messages @result.warning_array
end

json.custom_fields do
  json.array! @result.report.custom_fields
end

json.budgets do
  json.array! @result.budgets do |budget|
    json.extract! budget[:budget], :budgetable_id, :budgetable_type, :start_date, :id, :name, :purchase_order, :start_date, :end_date
    json.user budget[:budget].user.as_json
    json.spent_amount budget[:spent_amount]
    json.budget_amount budget[:budget].budget_amount.as_json
  end
end

travel_desk_enabled = @result.report.user.travel_desk_enabled?
json.show_trips travel_desk_enabled
if travel_desk_enabled
  json.user_travel_requests @result.report.user.travel_requests.reportable, :id, :name, :trip_id
  json.associated_trip @result.report.travel_request
end

# this will contain a summary of the user's account details
json.account_details do
  card = @result.report.user.cards.first
  cash_on_hand_pocket = @result.report.user.user_pockets.cash_pockets_only.first
  cash_on_hand_adapter = AccountManager::CashPockets::CashPocketsAdapter.new(cash_on_hand_pocket)
  finly_money_adapter = AccountManager::Wallet::WalletAdapter.new(@result.report.user.wallet)
  card_adapter = AccountManager::Cards::CardAdapter.new(@result.report.user.cards.first) if card.present?

  json.cash_on_hand_balance cash_on_hand_adapter.balance(display_balance: true)
  json.cash_on_hand_base_currency cash_on_hand_pocket.base_currency&.country_code
  if card.present?
    json.card_balance card_adapter.balance
    json.card_type "#{card.card_program&.name&.humanize} Card"
  end
  json.finly_money_balance finly_money_adapter.balance
end
json.reviewal_chains do
  json.array! @result.reviewal_chains do |chain|
    json.policy_id chain[:policy_id]
    json.reviewal_chain do
      json.array! chain[:reviewal_chain] do |item|
        json.level_number item[:level_number]
        json.level_id item[:level_id]
        json.selected_reviewer item[:selected_reviewer]&.as_json
        json.reviewers do
          json.array! item[:reviewers] do |reviewer|
            json.extract! reviewer, :id, :exception, :threshold
            json.reviewer_details reviewer.reviewer.as_json
          end
        end
      end
    end
  end
end

# json.reviewal_chain do
#   json.array! @result.reviewal_chain do |dlrm|
#     json.extract! dlrm, :policy_id, :level_id, :level_number, :taken_control
#     json.level_name dlrm.level.name
#     json.reviewer_details
#   end
# end
