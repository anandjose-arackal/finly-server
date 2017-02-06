item = @result.items
json.current_company_balance item[:current_company_balance]
json.total_amount_with_employees do
  json.total item[:total_amount_with_employees][:total]
  json.in_cards item[:total_amount_with_employees][:in_cards]
  json.in_finly_money item[:total_amount_with_employees][:in_finly_money]
  json.in_cash_on_hand item[:total_amount_with_employees][:in_cash_on_hand]
end
json.money_requests_awaiting_settlement do
  json.via_card item[:money_requests_awaiting_settlement][:via_card]
  json.via_cash item[:money_requests_awaiting_settlement][:via_cash]
end
json.reports_awaiting_settlement item[:reports_awaiting_settlement]
json.unreported_expenses do
  json.via_card_total item[:unreported_expenses][:via_card_total]
  json.via_card_number item[:unreported_expenses][:via_card_number]
  json.via_cash_total item[:unreported_expenses][:via_cash_count]
  json.via_cash_total item[:unreported_expenses][:via_cash_total]
end
