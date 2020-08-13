includes = [
    {initiating_user: :profile}, {amount: :currency}, {payment_order: :bank_payment_request}, :receiving_account_bank_account,
    :status,
    {
        invoice_parent: [
            :vendor, :status, :created_by,
            {procurement: :purchase_order}, {discount_amount: :currency},
            {tax_amount: :currency}, :tds_slab, {tds_amount: :currency},
            {freight_amount: :currency}, {net_amount: :currency},
            {paid_amount: :currency}, {balance_due: :currency},
            :policy, :gstin_location, :location, :delivery_location,
            {successful_payments: [amount: :currency]}
        ]
    },
    :purchase_order_parent,
    {
        receiving_user_vendor: [
            :vendor_type, :payment_term, :policy, :tds_rates, {gstin_locations: :state},
            :bank_accounts, :vendor_attachments, {custom_fields: :field_configuration}
        ]
    },
    :receiving_account_bank_account,
]
json.data do
  json.array! @op['model.records'].includes(includes) do |record|
    json.partial! 'payment', record: record
  end
end