class Docs::P2P::Invoices::Form < Forms::API

  model Invoice

  section :status do
    dropdown :invoice_status_id, choices_scope: Choices[:enum].(VendorStatus),
             required: false, editable: false, default_value: VendorStatus.id_for(:draft),
             can_editable_be_changed: false
  end

  section :header do
    text :invoice_number
    date :date, restriction: 'not_in_the_future'
    date :due_date, restriction: 'not_in_the_past'
    lookup :policy_id,
           choices_scope: Choices[:lookup].('policies'),
           #permissions: [:non_po_invoice_initiator]),
           required: true
    dropdown :cost_allocation_items, choices_scope: Choices[:list].({id: false, name: "Header"}, {id: true, name: "Line Item"}),
             required: true, can_choices_be_changed: false, default_value: false
    lookup :department_id, choices_scope: Choices[:lookup].('departments') #, editable: false, visible: false
    lookup :cost_center_id, choices_scope: Choices[:lookup].('cost_centers')
    date :transaction_service_period_from, label: 'Transaction Period From'
    date :transaction_service_period_to, label: 'Transaction Period To'
    large_text :narration
  end

  section :vendor_details do
    lookup :vendor_id, choices_scope: Choices[:lookup].('vendors'), required: true
    text :vendor_id, editable: false, computed: Forms::Compute::Lookup('vendor_id', '{{record.vendor_id}}')
    # Todo > Show field
    # text :pan, editable: false, computed: Forms::Compute::Lookup('vendor_id', '{{record.pan}}')
    lookup :gstin_location_id, label: 'Location', choices_scope: Choices[:lookup].('vendor_locations'),
           filters: Rules::Builder[:vendor_id].eq(entity: :vendor_id)
    # text :gstin, editable: false, computed: Forms::Compute::Lookup('gstin_location_id', '{{record.gstin}}')
    lookup :receiving_account_id, choices_scope: Choices[:lookup].('vendor_bank_accounts'),
           filters: Rules::Builder[:account_owner_id].eq(entity: 'vendor_id')
                        .and(Rules::Builder[:account_owner_type].eq(value: 'YesBankVendor'))
    text :receiving_account_type, internal: true, editable: false, computed: Forms::Compute::Form('BankAccount')
  end

  section :bill_to do
    lookup :location_id, label: 'Billing Address', choices_scope: Choices[:lookup].('locations'),
           filters: Rules::Builder['billable_location'].true, required: true
    # text :name, editable: false, computed: Forms::Compute::Lookup('location_id', '{{record.gstin}}')
    # text :gstin, editable: false, computed: Forms::Compute::Lookup('location_id', '{{record.name}}')
    large_text :billing_address, computed: Forms::Compute::Lookup('location_id', '{{record.address}}')
  end

  section :ship_to do
    lookup :delivery_location_id, label: 'Shipping Address', choices_scope: Choices[:lookup].('locations'),
           filters: Rules::Builder['shippable_location'].true, required: true
    # text :name, editable: false, computed: Forms::Compute::Lookup('delivery_location_id', '{{record.gstin}}')
    # text :gstin, editable: false, computed: Forms::Compute::Lookup('delivery_location_id', '{{record.name}}')
    large_text :shipping_address, computed: Forms::Compute::Lookup('delivery_location_id', '{{record.address}}')
  end

  section :items do
    table :items, populate_if_empty: InvoiceLineItem do
      number :id, visible: false, editable: false, internal: true, can_visible_be_changed: false, can_editable_be_changed: false
      lookup :inventory_line_item_id, choices_scope: Choices[:lookup].('items')
      text :description, editable: false, computed: Forms::Compute::Lookup('items.inventory_line_item_id', '{{record.description}}')
      text :comment
      # text :item_number, editable: false, computed: Forms::Compute::Lookup('items.inventory_line_item_id', '{{record.item_code}}')
      # dropdown :product_type_id, choices_scope: Choices[:enum].(ProductType), editable: false, computed: Forms::Compute::Lookup('items.inventory_line_item_id', '{{record.product_type_id}}')
      dropdown :department_id, editable: false, visible: false, choices_scope: Choices[:lookup].('departments'), computed: Forms::Compute::Form('{{form.department_id}}')
      dropdown :cost_center_id, editable: false, visible: false, choices_scope: Choices[:lookup].('cost_centers'), computed: Forms::Compute::Form('{{form.cost_center_id}}')
      dropdown :category_id, choices_scope: Choices[:lookup].('categories'), required: true, computed: Forms::Compute::Lookup('items.inventory_line_item_id', '{{record.category_id}}')
      # text :gl_code, editable: false, computed: Forms::Compute::Lookup('items.category_id', '{{record.gl_code}}')
      text :hsn_sac, computed: Forms::Compute::Lookup('items.inventory_line_item_id', '{{record.hsn_sac}}')
      number :quantity, required: true, min_value: 1
      dropdown :unit_of_measurement, choices_scope: Choices[:list].({id: "KG", value: "KG"})
      amount :rate, required: true
      amount :amount, editable: false, visible: false, computed: Forms::Compute::Form({value: "{{ row.rate.value | times: row.quantity }}", currency_id: "1"})
      number :discount_rate, max_value: 100, min_value: 0, format: 'percentage'
      amount :discount_amount, editable: false, computed: Forms::Compute::Form({value: "{{ row.amount.value | times: row.discount_rate | divided_by: 100 }}", currency_id: "1"})
      amount :taxable_amount, editable: false, computed: Forms::Compute::Form({value: "{{ row.amount.value | minus: row.discount_amount.value }}", currency_id: "1"})
      dropdown :tax_rate_id, choices_scope: Choices[:lookup].('tax_rates'), computed: Forms::Compute::Lookup('items.inventory_line_item_id', '{{record.tax_rate_id}}')
      number :tax_rate, editable: false, visible: false, computed: Forms::Compute::Lookup('items.tax_rate_id', '{{record.rate}}')
      amount :tax_amount, editable: false, computed: Forms::Compute::Form({value: "{{ row.taxable_amount.value | times: row.tax_rate | divided_by: 100 }}", currency_id: "1"})
      amount :net_amount, editable: false, computed: Forms::Compute::Form({value: "{{ row.taxable_amount.value | plus: row.tax_amount.value }}", currency_id: "1"})
    end
    table_summary :items_summary do
      amount :gross_amount, editable: false, computed: Forms::Compute::Form(
          value: "\
{% assign gross_total = 0 %}\
{% for item in form.items %}\
{% assign gross_total = gross_total | plus: item.amount.value %}\
{% endfor %}\
{{ gross_total }}",
          currency_id: "1"
      )
      amount :discount_amount, editable: false, computed: Forms::Compute::Form(
          value: "\
{% assign discount_amount = 0 %}\
{% for item in form.items %}\
{% assign discount_amount = discount_amount | plus: item.discount_amount.value %}\
{% endfor %}\
{{ discount_amount }}",
          currency_id: ""
      )
      amount :tax_amount, editable: false, computed: Forms::Compute::Form(
          value: "\
{% assign tax_amount = 0 %}\
{% for item in form.items %}\
{% assign tax_amount = tax_amount | plus: item.tax_amount.value %}\
{% endfor %}\
{{ tax_amount }}",
          currency_id: "1"
      )
      dropdown :tds_slab_id, choices_scope: Choices[:lookup].('tds_slabs')
      number :tds_rate, internal: true, editable: false, computed: Forms::Compute::Lookup('items_summary.tds_slab_id', '{{record.rate}}')
      amount :tds_amount, editable: false, computed: Forms::Compute::Form(value: '{{ form.gross_amount.value | times: form.tds_rate | divided_by: 100 }}', currency_id: 1)
      amount :net_amount, editable: false, computed: Forms::Compute::Form(value: '{{ form.gross_amount.value | minus: form.discount_amount.value | plus: form.tax_amount.value }}', currency_id: 1)
    end
  end

  section :attachments do
    attachment :attachments
  end

  condition condition_id: "Receiving Account Type can only be active if Receiving Account ID is set" do
    reference 'entity', 'receiving_account_type'
    rule Rules::Builder['receiving_account_id'].present
    action :active, true
  end

  condition condition_id: 'Enable line item department for item level cost allocation' do
    reference 'entity', 'items.department_id'
    rule Rules::Builder['cost_allocation_items'].true
    action :visible, true
    action :editable, true
  end

  condition condition_id: 'Enable line item cost center for item level cost allocation' do
    reference 'entity', 'items.cost_center_id'
    rule Rules::Builder['cost_allocation_items'].true
    action :visible, true
    action :editable, true
  end

  condition condition_id: 'Disable line item department for header level cost allocation' do
    reference 'entity', 'items.department_id'
    rule Rules::Builder['cost_allocation_items'].false
    action :visible, false
    action :editable, false
  end

  condition condition_id: 'Disable line item cost center for header level cost allocation' do
    reference 'entity', 'items.cost_center_id'
    rule Rules::Builder['cost_allocation_items'].false
    action :visible, false
    action :editable, false
  end

  condition condition_id: 'Disable header department for item level cost allocation' do
    reference 'entity', 'department_id'
    rule Rules::Builder['cost_allocation_items'].true
    action :visible, false
    action :editable, false
  end

  condition condition_id: 'Disable header cost_center for item level cost allocation' do
    reference 'entity', 'cost_center_id'
    rule Rules::Builder['cost_allocation_items'].true
    action :visible, false
    action :editable, false
  end

  condition condition_id: 'Enabled header department for header level cost allocation' do
    reference 'entity', 'department_id'
    rule Rules::Builder['cost_allocation_items'].false
    action :visible, true
    action :editable, true
  end

  condition condition_id: 'Enabled header cost_center for header level cost allocation' do
    reference 'entity', 'cost_center_id'
    rule Rules::Builder['cost_allocation_items'].false
    action :visible, true
    action :editable, true
  end

  validation validation_id: :due_date_gteq_invoice_date do
    reference 'due_date'
    error_message "Due Date cannot be before the invoice date"
    rule Rules::Builder['due_date'].lt(entity: "date")
  end


end