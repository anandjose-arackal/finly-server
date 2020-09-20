includes = [
    :vendor, :status, :created_by,
    :policy, :gstin_location, :location, :delivery_location, :attachments,
    {
        items: [
            :inventory_line_item, :category, :department, :cost_center, :tax_rate,
            {total_amount: :currency}, {discount_amount: :currency}, {taxable_amount: :currency}, :tax_rate,
            {tax_amount: :currency}, {tds_amount: :currency }
        ]
    },
    {dlrms: [:level, :action, :action_taken_by]}
    # {custom_fields: :field_configuration},
]

json.data do
  json.array! @op['model.records'].includes(includes) do |record|
    json.partial! 'purchase_order', record: record
  end
end