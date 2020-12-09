includes = [
    :vendor, :status, :created_by,:department,:cost_center,
    :policy, :shipping_location,:billing_location,:invoice,:attachments,
    {procurement: :purchase_order}, {discount_amount: :currency},
    {tax_amount: :currency}, {tds_amount: :currency},
    {freight_amount: :currency},{net_receivable_amount: :currency},
    {previously_adjusted_amount: :currency},{net_adjustable_amount: :currency},
    {dlrms: [:level, :action, :action_taken_by]},
    items: [
           :item,:invoice_item, :credit_note_item_type, :category,  :tax_rate,
           {taxable_amount: :currency}, :tax_rate,{original_taxable_amount: :currency},
           {tax_amount: :currency}, {total_amount: :currency}
        ]
    ]
json.data do
  json.array! @op['model.records'].includes(includes) do |record|
    json.partial! 'credit_note', record: record
  end
end