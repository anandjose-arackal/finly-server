# ar = [
#     {id: 1, invoice_number: '12232323', date: '12-01-2018', due_date: '13-01-2018', customer: {id: 1, name: "Ramesh Narayan"}, balance_due: 234.50, status: 'Open'},
#     {id: 1, invoice_number: '12232323', date: '12-01-2018', due_date: '13-01-2018', customer: {id: 1, name: "Ramesh Narayan"}, balance_due: 234.50, status: 'Open'},
#     {id: 1, invoice_number: '12232323', date: '12-01-2018', due_date: '13-01-2018', customer: {id: 1, name: "Ramesh Narayan"}, balance_due: 234.50, status: 'Open'},
#     {id: 1, invoice_number: '12232323', date: '12-01-2018', due_date: '13-01-2018', customer: {id: 1, name: "Ramesh Narayan"}, balance_due: 234.50, status: 'Open'},
#     {id: 1, invoice_number: '12232323', date: '12-01-2018', due_date: '13-01-2018', customer: {id: 1, name: "Ramesh Narayan"}, balance_due: 234.50, status: 'Open'},
#     {id: 1, invoice_number: '12232323', date: '12-01-2018', due_date: '13-01-2018', customer: {id: 1, name: "Ramesh Narayan"}, balance_due: 234.50, status: 'Open'}
# ]
#
# json.array! ar

json.array!(@result.invoices) do |invoice|
  json.id invoice.id
  json.invoice_number invoice.invoice_number
  json.date invoice.invoice_date
  json.due_date invoice.invoice_due_date
  json.customer do
    json.id invoice.customer&.id
    json.name invoice.customer&.name
  end
  json.balance_due invoice.balance_due&.value
  json.status invoice.invoice_status&.name
end