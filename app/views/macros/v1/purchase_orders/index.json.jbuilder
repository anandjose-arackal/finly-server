includes = [
    :vendor, :status, :created_by,
    :policy, :gstin_location, :location, :delivery_location,
    {
        items: [
            :inventory_line_item, :category, :department, :cost_center, :tax_rate,
            {amount: :currency}, {discount_amount: :currency}, {taxable_amount: :currency}, :tax_rate,
            {tax_amount: :currency}, {net_amount: :currency}
        ]
    },
    {dlrms: [:level, :action, :action_taken_by]},
    {custom_fields: :field_configuration},
    :attachments
]
json.data do
  json.array! @op['model.records'].includes(includes) do |record|
    json.partial! 'purchase_order', record: record
  end
end