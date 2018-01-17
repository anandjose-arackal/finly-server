json.summary do
  json.order_status do
    json.name "Junk status"
    json.identifier 'junk_status'
  end
  json.invoice_number 'INV001'
  json.invoice_date '23rd Jan 2018'
  json.due_date '25rd Jan 2018'

  json.payment_term_name 'NET 30'
  json.payment_term_id 1


  json.policy do
    json.id 1
    json.name "junk Policy"
  end

  json.shipping_address do
    # shiping address details
  end

  json.billing_address do
    # shiping address details
  end
end

json.customer do
  json.name "Mr. Junkie"
  json.mobile_number '7406032047'
  json.email 'junkieboye@grr.la'
end

invoice_items = [
    HashWithIndifferentAccess.new({rate: 10, quantity: 12, amount: 120, tax: 5, discount: 7, tax_amount: 5.1, discount_amount: 8.043, category_name: 'Junk Category', id: 1, description: 'Junk Item 1', total_amount: 106.857, hsn_sac: "JNK"}),
    HashWithIndifferentAccess.new({rate: 10, quantity: 12, amount: 120, tax: 5, discount: 7, tax_amount: 5.1, discount_amount: 8.043, category_name: 'Junk Category', id: 2, description: 'Junk Item 1', total_amount: 106.857, hsn_sac: "JNK"}),
    HashWithIndifferentAccess.new({rate: 10, quantity: 12, amount: 120, tax: 5, discount: 7, tax_amount: 5.1, discount_amount: 8.043, category_name: 'Junk Category', id: 3, description: 'Junk Item 1', total_amount: 106.857, hsn_sac: "JNK"}),
    HashWithIndifferentAccess.new({rate: 10, quantity: 12, amount: 120, tax: 5, discount: 7, tax_amount: 5.1, discount_amount: 8.043, category_name: 'Junk Category', id: 4, description: 'Junk Item 1', total_amount: 106.857, hsn_sac: "JNK"}),
    HashWithIndifferentAccess.new({rate: 10, quantity: 12, amount: 120, tax: 5, discount: 7, tax_amount: 5.1, discount_amount: 8.043, category_name: 'Junk Category', id: 5, description: 'Junk Item 1', total_amount: 106.857, hsn_sac: "JNK"}),
]


json.invoice do
  json.total_amount 98.5
  json.advance 10
  json.advance_amount 20
  json.gst_type_id 1
  json.freight_amount 20
  json.roundoff_amount 0.5
  json.balance_due 99

  json.invoice_items do
    json.array!(invoice_items) do |item|
      json.rate item[:rate]
      json.quantity item[:quantity]
      json.tax item[:tax]
      json.discount item[:discount]
      json.category_id item[:category_id]
      json.tax_amount precision_value item[:tax_amount]
      json.discount_amount precision_value item[:discount_amount]
      json.amount precision_value item[:amount]
      json.category_name item[:category]
      json.id item[:id]
      json.description item[:description]
      json.total_amount precision_value item[:net_amount]
      json.hsn_sac item[:hsn_sac]
    end
  end
end
