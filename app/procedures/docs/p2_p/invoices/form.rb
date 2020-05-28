class Docs::P2P::Invoices::Form < Forms::API

  model Invoice

  section :status do
    dropdown :invoice_status_id, choices_scope: Choices[:enum].(VendorStatus),
             required: false, editable: false, default_value: VendorStatus.id_for(:draft),
             can_editable_be_changed: false
  end

  section :header do
    text :invoice_number
    date :invoice_date, restriction: 'not_in_the_future'
    date :due_date, restriction: 'not_in_the_past'
    lookup :policy_id,
           choices_scope: Choices[:lookup].('policies',
               permissions: [:non_po_invoice_initiator]),
           required: true
    dropdown :cost_allocation_items, choices_scope: Choices[:list].({id: 1, name: "Header"}, {id: 2, name: "Line Item"}),
             required: true, can_choices_be_changed: false, default_value: 1
    lookup :department_id, choices_scope: Choices[:lookup].('departments') #, editable: false, visible: false
    lookup :cost_center_id, choices_scope: Choices[:lookup].('cost_centers')
    date :transaction_service_period_from, label: 'Transaction Period From'
    date :transaction_service_period_to, label: 'Transaction Period To'
    large_text :narration
  end

  section :vendor_details do
    lookup :vendor_id, choices_scope: Choices[:lookup].('vendors'), required: true
    text :vendor_id, editable: false, computed: Forms::Compute::Lookup('vendor_id', '{{record.vendor_id}}')
    text :pan, editable: false, computed: Forms::Compute::Lookup('vendor_id', '{{record.pan}}')
    lookup :gstin_location_id, label: 'Location', choices_scope: Choices[:lookup].('vendor_locations'),
           filters: Rules::Builder[:vendor_id].eq(entity: :vendor_id)
    text :gstin, editable: false, computed: Forms::Compute::Lookup('gstin_location_id', '{{record.gstin}}')
    lookup :receiving_account_id, choices_scope: Choices[:lookup].('bank_accounts'),
           filters: Rules::Builder[:account_owner_id].eq(entity: 'vendor_id')
                        .and(Rules::Builder[:account_owner_type].eq(value: 'YesBankVendor'))
    text :receiving_account_type, default_value: "BankAccount", internal: true
  end

  section :bill_to do
    lookup :location_id, label: 'Billing Address', choices_scope: Choices[:lookup].('locations'),
           filters: Rules::Builder['billable_location'].true, required: true
    text :name, editable: false, computed: Forms::Compute::Lookup('location_id', '{{record.gstin}}')
    text :gstin, editable: false, computed: Forms::Compute::Lookup('location_id', '{{record.name}}')
    large_text :name, computed: Forms::Compute::Lookup('location_id', '{{record.gstin}}')
  end

  section :ship_to do
    lookup :delivery_location_id, label: 'Shipping Address', choices_scope: Choices[:lookup].('locations'),
           filters: Rules::Builder['shippable_location'].true, required: true
    text :name, editable: false, computed: Forms::Compute::Lookup('delivery_location_id', '{{record.gstin}}')
    text :gstin, editable: false, computed: Forms::Compute::Lookup('delivery_location_id', '{{record.name}}')
    large_text :name, computed: Forms::Compute::Lookup('delivery_location_id', '{{record.gstin}}')
  end

  section :line_items do
    table :line_items do
      lookup :inventory_line_item_id, choices_scope: Choices[:lookup].('items')
      text :description, editable: false, computed: Forms::Compute::Lookup('inventory_line_item_id', '{{record.description}}')
      text :comment
      text :item_number, editable: false, computed: Forms::Compute::Lookup('inventory_line_item_id', '{{record.item_code}}')
      dropdown :product_type_id, choices_scope: Choices[:enum].(ProductType), editable: false, computed: Forms::Compute::Lookup('inventory_line_item_id', '{{record.product_type_id}}')
      dropdown :department_id, editable: false, visible: false, choices_scope:  Choices[:lookup].('departments'), computed: Forms::Compute::Form('{{form.department_id}}')
      dropdown :cost_center_id, editable: false, visible: false, choices_scope:  Choices[:lookup].('cost_centers'), computed: Forms::Compute::Form('{{form.cost_center_id}}')
      dropdown :category_id, choices_scope:  Choices[:lookup].('categories'), required: true, computed: Forms::Compute::Lookup('inventory_line_item_id', '{{record.category_id}}')
      text :hsn_sac, computed: Forms::Compute::Lookup('inventory_line_item_id', '{{record.hsn_sac}}')
      number :quantity, required: true, min_value: 1
      dropdown :unit_of_measurement, choices_scope: Choices[:list].({id: "KG", value: "KG"})
      amount :rate, required: true
      amount :amount, editable: false, visible: false, computed: Forms::Compute::Form("{{ row.rate | times: row.quantity }}")
      number :discount_rate, max_value: 100, min_value: 0
      amount :discount_amount, editable: false, computed: Forms::Compute::Form("{{ row.amount | times: row.discount | divided_by: 100 }}")
      amount :gross_amount, editable: false, computed: Forms::Compute::Form("{{ row.amount | minus: row.discount_amount }}")
      dropdown :tax_rate_id, choices_scope: Choices[:lookup].('tax_rates'), computed: Forms::Compute::Lookup('inventory_line_item_id', '{{record.tax_rate_id}}')gi
      number :tax_rate, editable: false, visible: false, computed: Forms::Compute::Lookup('tax_rate_id', '{{record.rate}}')
      amount :tax_amount, editable: false, computed: Forms::Compute::Form("{{ row.taxable_amount | times: row.discount_amount }}")
      amount :net_amount, editable: false, computed: Forms::Compute::Form("{{ row.gross_amount | minus: row.tax_amount }}")
    end
  end

  condition condition_id: :receiving_account_type_setter do
    reference 'entity', 'receiving_account_type'
    rule Rules::Builder['receiving_account_id'].present
    action :active, true
  end

  condition condition_id: :cost_allocation_department_setter do
    reference 'entity', 'line_items/department_id'
    rule Rules::Builder['cost_allocation_items'].true
    action :visible, true
    action :editable, true
  end

  condition condition_id: :cost_allocation_cost_center_setter do
    reference 'entity', 'line_items/cost_center_id'
    rule Rules::Builder['cost_allocation_items'].true
    action :visible, true
    action :editable, true
  end

  condition condition_id: :cost_allocation_department_unsetter do
    reference 'entity', 'line_items/department_id'
    rule Rules::Builder['cost_allocation_items'].false
    action :visible, false
    action :editable, false
  end

  condition condition_id: :cost_allocation_cost_center_unsetter do
    reference 'entity', 'line_items/cost_center_id'
    rule Rules::Builder['cost_allocation_items'].false
    action :visible, false
    action :editable, false
  end

  condition condition_id: :cost_allocation_department_visible_toggle do
    reference 'entity', 'department_id'
    rule Rules::Builder['cost_allocation_items'].true
    action :visible, false
    action :editable, false
  end

  condition condition_id: :cost_allocation_cost_center_visible_toggle do
    reference 'entity', 'cost_center_id'
    rule Rules::Builder['cost_allocation_items'].true
    action :visible, false
    action :editable, false
  end

  validation validation_id: :due_date_gteq_invoice_date do
    reference 'due_date'
    error_message "Due Date cannot be before the invoice date"
    rule Rules::Builder['due_date'].gteq(entity: "invoice_date")
  end


end