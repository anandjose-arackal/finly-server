class Analytics::Master::Transactions::Contracts::InvoiceItem < Transactions::Contract

  def self.map(prop)
    property prop, deserialize(-> (input, represented, record:, **) do
      represented.send("#{prop}=", yield)
    end)
  end

  map :entity do
    record
  end
  map :parent do
    record.invoice
  end
  map :company do
    record.user.company
  end
  map :company_name do
    record.user.company.name
  end
  map :category do
    record.category
  end
  map :category_name do
    record.category.name
  end
  map :gl_code do
    record.category.gl_code
  end
  map :cost_center_id do
    record.cost_center_id
  end
  map :cost_center_name do
    record.cost_center&.name
  end
  map :parent_billing_location_id do
    record.invoice.billing_location.parent_id
  end
  map :parent_billing_location_name do
    record.invoice.billing_location.parent&.name
  end
  map :billing_location_id do
    record.invoice.billing_location.parent_id
  end
  map :billing_location_name do
    record.invoice.billing_location.parent&.name
  end
  map :parent_shipping_location_id do
    record.invoice.billing_location.parent_id
  end
  map :parent_shipping_location_name do
    record.invoice.billing_location.parent&.name
  end
  map :shipping_location_id do
    record.invoice.billing_location.parent_id
  end
  map :shipping_location_name do
    record.invoice.billing_location.parent&.name
  end
  map :parent_department_id do
    record.invoice.billing_location.parent_id
  end
  map :parent_department_name do
    record.invoice.billing_location.parent&.name
  end
  map :department_id do
    record.invoice.billing_location.parent_id
  end
  map :department_name do
    record.invoice.billing_location.parent&.name
  end
  map :vendor_id do
    record.invoice.billing_location.parent&.name
  end
  map :vendor_name do
    record.invoice.billing_location.parent&.name
  end
  map :vendor_legal_name do
    record.invoice.billing_location.parent&.name
  end
  map :vendor_trade_name do
    record.invoice.billing_location.parent&.name
  end
  map :vendor_location_id do
    record.invoice.billing_location.parent&.name
  end
  map :vendor_location_name do
    record.invoice.billing_location.parent&.name
  end


end