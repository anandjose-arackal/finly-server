json.email @result.email
json.companies do
  json.array!(@result.companies) do |company|
    json.name company.name
    json.logo company.configuration.logo.url
    json.company_id company.id
    json.expense_management company.expense_management_enabled?
    json.vendor_payments company.vendor_payments_enabled?
    json.insights company.budgeting_system_enabled?
    json.fund_disbursement company.cards_enabled?
    json.collect company.invoicing_system_enabled?
  end
end