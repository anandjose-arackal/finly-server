item = @result.items

json.company_account_opening_balance item[:company_account_opening_balance]
json.company_account_closing_balance item[:company_account_closing_balance]
json.company_account_details do
  json.total_account_load_via_NEFT item[:total_account_load_via_NEFT]
  json.loads do
    json.array! item[:company_account_details][:loads] do |load|
      json.date load[:date]
      json.amount load[:amount]
    end
  end
end
json.transfers_from_company_account do
  json.total item[:transfers_from_company_account][:total]
  json.admin_transfers do
    json.array! item[:transfers_from_company_account][:admin_transfers] do |transfer|
      json.name transfer[:name]
      json.amount transfer[:amount]
    end
  end
end
json.transfers_to_company_account do
  json.total item[:transfers_to_company_account][:total]
  json.admin_transfers do
    json.array! item[:transfers_to_company_account][:admin_transfers] do |transfer|
      json.name transfer[:name]
      json.amount transfer[:amount]
    end
  end
end
json.total_amount_transferred_from_company_account do
  json.to_finly_cards item[:total_amount_transferred][:to_finly_cards]
  json.to_finly_money item[:total_amount_transferred][:to_finly_money]
end
json.total_amount_transferred_to_company_account do
  json.from_finly_cards item[:total_amount_transferred][:from_finly_cards]
  json.from_finly_money item[:total_amount_transferred][:from_finly_money]
end