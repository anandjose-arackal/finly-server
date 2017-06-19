json.messages []
expensed = (@result.success? and @result.receipt_email&.expense.present?)
json.expensed expensed
json.parsed @result.success?
json.editable (expensed and @result.receipt_email.expense.editable?)
if @result.success?
  json.expense do
    data = @result.data
    json.id data[:id]
    json.merchant data[:merchant]
    json.date data[:date]
    json.note data[:note]
    json.category do
      json.id data[:category][:id]
      json.name data[:category][:name]
    end
    json.reimbursable data[:reimbursable]
    json.amount do
      json.value data[:amount]&.dig(:value)
      json.currency do
        json.id data[:amount][:currency][:id]
        json.country data[:amount][:currency][:country]
        json.country_code data[:amount][:currency][:country_code]
        json.symbol data[:amount][:currency][:symbol]
      end
    end
    json.custom_fields data[:custom_fields]
  end
end
