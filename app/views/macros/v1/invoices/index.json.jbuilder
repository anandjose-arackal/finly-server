includes = [
    :vendor, :status, :created_by,
    {procurement: :purchase_order}, {discount_amount: :currency},
    {tax_amount: :currency}, :tds_slab, {tds_amount: :currency},
    {freight_amount: :currency}, {net_amount: :currency},
    {paid_amount: :currency}, {balance_due: :currency},
    :policy, :gstin_location, :location, :delivery_location,
    {successful_payments: [amount: :currency]},
    {
        items: [
            :inventory_line_item, :category, :department, :cost_center, :tax_rate,
            {amount: :currency}, {discount_amount: :currency}, {taxable_amount: :currency}, :tax_rate,
            {tax_amount: :currency}, {net_amount: :currency}
        ]
    },
    :attachments
]
json.data do
  json.array! @op['model.records'].includes(includes) do |record|
    json.partial! 'invoice', record: record
  end
end