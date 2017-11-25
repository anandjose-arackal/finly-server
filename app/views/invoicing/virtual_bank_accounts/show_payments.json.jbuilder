# clients = [{source_account: {name: 'Intel', ifsc: 'HDFC0912312', account_number: '09182390189012111'}, amount: '15000', note: 'Clearing Invoice 1982901381', date: '27-10-2017'},
#            {source_account: {name: 'SuprDaily', ifsc: 'HDFC6715231', account_number: '91273981729311'}, amount: '20000', note: 'Payment on Invoice', date: '27-10-2017'},
#            {source_account: {name: 'Hibiscus Technologies', ifsc: 'IDBI817239812', account_number: '1267531726312'}, amount: '90000', note: 'Balance Clearance', date: '27-10-2017'},
#            {source_account: {name: 'Rajesh Consultants', ifsc: 'ICICI182739817231', account_number: '18726391082031'}, amount: '280000', note: 'Consultancy Payment', date: '27-10-2017'}]
# json.transactions do
#   json.array! clients
# end


json.transactions do
  json.array!(@result.payments) do |payment|
    json.source_account do
      virtual_trans = payment.reference_resource
      json.name virtual_trans&.remitter_full_name
      json.ifsc virtual_trans&.remitter_account_ifsc
      json.account_number virtual_trans&.remitter_account_no
    end
    json.amount payment.amount_value
    json.note payment.reference_resource&.note
    json.date payment.date
  end
end