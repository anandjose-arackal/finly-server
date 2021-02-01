class Docs::P2P::Invoices::Form < Forms::API

  model Invoice

  # LIQUID FORMULAE
  LIQUID_FORMULAE = {
      items: {
          item_gross_amount: "{{ row.rate | times: row.quantity | round: 2 }}",
          item_discount_amount: "{% if accounting_details.discount_type == percentage %}{{ row.item_gross_amount | times: row.discount | divided_by: 100 | round: 2}}{% elsif accounting_details.discount_type == amount %}{{ row.discount }}{% else %}{{ 0 }}{% endif %}",
          item_taxable_amount: "{{ row.item_gross_amount | minus: row.item_discount_amount | round: 2 }}",
          item_tax_amount: "{{ row.item_taxable_amount | times: row.tax_percentage | divided_by: 100 | round: 2 }}",
          item_tds_amount: "{% if row.tds_applicable == true %}{{ row.item_taxable_amount | times: form.tds_percentage | divided_by: 100 | round: 2}}{% else %}{{ 0 }}{% endif %}",
          item_net_amount: "{{ row.item_taxable_amount | plus: row.item_tax_amount | round: 2 }}",
          item_billable_amount: "{{ row.item_taxable_amount | plus: row.item_tax_amount | minus: row.item_tds_amount | round: 2 }}", # todo - I2P will be different for PO invoice          
      },
      # INVOICE SUMMARY
      summary: {
          invoice_gross_amount: "{% assign gross_amount = 0 %}{% for item in form.items %}{% assign gross_amount = gross_amount | plus: item.item_gross_amount %}{% endfor %}{{ gross_amount | round: 2 }}",
          
          total_line_item_discount_amount: "{% assign discount_amount = 0 %}{% for item in form.items %}{% assign discount_amount = discount_amount | plus: item.item_discount_amount %}{% endfor %}{{ discount_amount | round: 2 }}",
          overall_discount_amount: "{{ row.overall_discount_amount | round: 2  }}",
          invoice_discount_amount: "{{ total_line_item_discount_amount | plus: overall_discount_amount | round: 2 }}",
          
          invoice_taxable_amount: "{{ form.invoice_gross_amount | minus: form.invoice_discount_amount }}",
          invoice_tax_amount: "{% assign tax_amount = 0 %}{% for item in form.items %}{% assign tax_amount = tax_amount | plus: item.item_tax_amount %}{% endfor %}{{ tax_amount | round: 2 }}",
          invoice_tds_amount: "{% assign tds_amount = 0 %}{% for item in form.items %}{% assign tds_amount = tds_amount | plus: item.item_tds_amount %}{% endfor %}{{ tds_amount | round: 2 }}",
          invoice_sub_total_amount: "{{ form.invoice_gross_amount | minus: form.invoice_discount_amount | plus: form.invoice_tax_amount | plus: form.invoice_freight_amount | minus: form.invoice_tds_amount | round: 2 }}",
          # todo - Issue : Roundoff should be automatically calulated everytime user inputs something, even if its the round off itself
          invoice_roundoff_amount: "{% assign amount = form.invoice_sub_total_amount | round %}{{amount | minus: form.invoice_sub_total_amount | round: 2 }}",
          invoice_total_amount: "{{ form.invoice_sub_total_amount | plus: form.invoice_roundoff_amount | round: 2 }}",
          invoice_net_total_amount: "{{ form.invoice_total_amount | minus: form.invoice_paid_outside_amount | minus: form.invoice_advance_paid_amount | round: 2 }}",
          # todo - will be shown on top of invoice and needs separate calculation
          # invoice_balance_due: "{{ form.invoice_total_amount | minus: form.invoice_advance_paid_amount | round: 2 }}",          
          invoice_balance_due: "{{ form.invoice_total_amount | minus: form.invoice_advance_paid_amount | minus: form.invoice_paid_outside_amount | round: 2 }}",
          invoice_balance_due_converted: "{{ form.invoice_balance_due | times: form.conversion_rate | round: 2 }}"

      }
  }


  # INVOICE STATUS
  section :status do
    lookup :invoice_status_id,
           choices_scope: Choices[:enum].(InwardInvoiceStatus),
           required: false, editable: false,
           default_value: InwardInvoiceStatus.id_for(:open),
           can_editable_be_changed: false
  end

  # INVOICE DETAILS
  section :invoice_details, title: "Invoice Details", associate_custom_fields: true do
    auto_number :invoice_id,
               label: "Sequence Number",
               editable: false,
               sequence: {prefix: "INV-", start_at: '00001'}

    text :invoice_number,
         label: "Invoice Number",
         required: true

    date :date,
         label: "Invoice Date",
         required: true,
         restriction: 'not_in_the_future'

    lookup :payment_term_id,
           choices_scope: Choices[:lookup].('payment_terms'),
           label: "Payment Term",
           visible: true, required: true, editable: true
    
    number :payment_term_days,
         label: "Payment Term Days",
         computed: Forms::Compute::Lookup('payment_term_id', '{{record.days_after}}'),
         visible: false
    
    # can_choices_be_changed: false, default_value: false
    # '{% assign assigne_days = form.payment_term_days | times: 86400 %}{{ form.date | date: "%s" | plus: assigne_days | date: "%d-%m-%Y" }}'
    date :due_date,
      computed: Forms::Compute::Form('{% assign assigne_days = form.payment_term_days | times: 86400 %}{{ form.date | date: "%s" | plus: assigne_days | date: "%Y-%m-%d" }}'),
      visible: true, required: true, editable: true


    dropdown :cost_allocation_items, choices_scope: Choices[:list].({id: false, name: "Header"}, {id: true, name: "Line Item"}),
             required: true, can_choices_be_changed: false, default_value: false

    date :transactions_service_period_form, label: 'Transaction Service Period (From Date)', editable: true, visible: true
    date :transactions_service_period_to, label: 'Transaction Service Period (To Date)', editable: true, visible: true

  end

  # ACCOUNTING DETAILS
  section :accounting_details, title: "Accounting Details", associate_custom_fields: true do
    lookup :policy_id,
         choices_scope: Choices[:lookup].('policies'),
         #permissions: [:non_po_invoice_initiator]),
         required: true, editable: false
    lookup :department_id, label: "Department", editable: true, visible: true, required: true, choices_scope: Choices[:lookup].('departments') #, editable: false, visible: false
    lookup :cost_center_id, label: "Cost Center", editable: true, visible: true, required: true, choices_scope: Choices[:lookup].('cost_centers')
    dropdown :discount_type, label: "Discount Type", editable: true, visible: true, required: true, choices_scope: Choices[:list].({id: '', name: 'None'} , {id: 'percentage', name: 'percentage'}, {id: 'amount', name: 'Amount'} ), default_value: ""
    date :conversion_date, label: "Conversion Date", editable: false, visible: true,
         computed: Forms::Compute::Form('{{form.date}}')

    currency :reporting_currency, label: "Reporting Currency"
    currency :base_currency, label: "Base Currency", visible: false, editable: false, can_editable_be_changed: false # todo populate with system base currency
    switch :retrieve_conversion_rate, label: "Auto Populate Conversion Rate", default_value: true, visible: false
    number :conversion_rate, editable: false, format: 'decimal', default_value: 1, visible: false
    # date :transaction_service_period_from, label: 'Transaction Period From'
    # date :transaction_service_period_to, label: 'Transaction Period To'
    large_text :narration, label: "Narration"
  end

  # VENDOR DETAILS
  section :vendor_details, title: "Vendor Details", associate_custom_fields: true do
    lookup :vendor_id, label: "Vendor", choices_scope: Choices[:lookup].('vendors'), required: true, editable: false,
           can_editable_be_changed: false, can_be_disabled: false, can_required_be_changed: false, can_visible_be_changed: false
    
    text :vendor_trade_name, label: 'Vendor Trade Name', editable: false, visible: true, computed: Forms::Compute::Lookup('vendor_id', '{{record.business_name}}')
    text :vendor_country, editable: false, visible: false
    
    text :vendor_sequence_id, "Vendor ID", editable: false, computed: Forms::Compute::Lookup('vendor_id', '{{record.vendor_id}}')

    lookup :gstin_location_id, label: 'Vendor Location', choices_scope: Choices[:lookup].('vendor_locations'), # todo - condition to hide for international
            filters: Rules::Builder[:vendor_id].eq(entity: :vendor_id)
    text :vendor_gstin, "Vendor GSTIN", editable: false, computed: Forms::Compute::Lookup('gstin_location_id', '{{record.gstin}}') # todo - condition
    text :vendor_pan, "Vendor PAN", editable: false # todo - add condition
    lookup :receiving_account_id, label: "Vendor Account", choices_scope: Choices[:lookup].('vendor_bank_accounts'),
           filters: Rules::Builder[:account_owner_id].eq(entity: 'vendor_id').and(Rules::Builder[:account_owner_type].eq(value: 'YesBankVendor')),
           editable: true, visible: true, required: true
    text :receiving_account_type, visible: false, internal: true, editable: false, computed: Forms::Compute::Form('BankAccount')
    text :vendor_bank_account_number, editable: false, can_editable_be_changed: false, computed: Forms::Compute::Lookup('receiving_account_id', '{{record.account_number}}')
    text :vendor_bank_account_ifsc, editable: false, required: true, can_editable_be_changed: false, computed: Forms::Compute::Lookup('receiving_account_id', '{{record.ifsc}}')
    text :vendor_bank_account_swift_code, editable: false, visible: false, required: false, can_editable_be_changed: false, computed: Forms::Compute::Lookup('receiving_account_id', '{{record.swift_code}}')
  end

  # BILLING ADDRESS
  section :billing_address do
    lookup :location_id, label: 'Billing Address', choices_scope: Choices[:lookup].('locations'),
           filters: Rules::Builder['billable_location'].true, required: true
    # text :name, editable: false, computed: Forms::Compute::Lookup('location_id', '{{record.gstin}}')
    # text :gstin, editable: false, computed: Forms::Compute::Lookup('location_id', '{{record.name}}')
    large_text :billing_address, computed: Forms::Compute::Lookup('location_id', '{{record.address}}')
  end

  # SHIPPING ADDRESS
  section :shipping_address do
    lookup :delivery_location_id, label: 'Shipping Address', choices_scope: Choices[:lookup].('locations'),
           filters: Rules::Builder['shippable_location'].true, required: true
    # text :name, editable: false, computed: Forms::Compute::Lookup('delivery_location_id', '{{record.gstin}}')
    # text :gstin, editable: false, computed: Forms::Compute::Lookup('delivery_location_id', '{{record.name}}')
    large_text :shipping_address, computed: Forms::Compute::Lookup('delivery_location_id', '{{record.address}}')
  end

  # INVOICE ITEMS
  section :items, associate_custom_fields: true do
    table :items, min_items: 1, populate_if_empty: InvoiceLineItem do
      number :id, visible: false, editable: false, internal: true, can_visible_be_changed: false, can_editable_be_changed: false

      lookup :inventory_line_item_id, label: "Item",
             can_visible_be_changed: false,
             can_editable_be_changed: false,
             choices_scope: Choices[:lookup].('items'),
             required: true, editable: true, visible: true

      text :description, editable: false,
           can_editable_be_changed: false,
           can_visible_be_changed: false,
           computed: Forms::Compute::Lookup('items.inventory_line_item_id', '{{record.description}}')

      text :comment, label: "Narration"
      text :item_number, label: "Item Code", editable: false, computed: Forms::Compute::Lookup('items.inventory_line_item_id', '{{record.item_code}}')

      lookup :product_type_id, label: "Product Type", choices_scope: Choices[:enum].(ProductType), computed: Forms::Compute::Lookup('items.inventory_line_item_id', '{{record.product_type_id}}'), editable: false, required: true, visible: true
      
      lookup :department_id, label: "Department", editable: false, visible: false, required: false, choices_scope: Choices[:lookup].('departments'), computed: Forms::Compute::Form('{{form.department_id}}')
      lookup :cost_center_id, label: "Cost Center", editable: false, visible: false, required: false, choices_scope: Choices[:lookup].('cost_centers'), computed: Forms::Compute::Form('{{form.cost_center_id}}')
      
      lookup :category_id, label: "Category", required: true, visible: true, editable: true, choices_scope: Choices[:lookup].('categories'), computed: Forms::Compute::Lookup('items.inventory_line_item_id', '{{record.category_id}}')

      text :gl_code, label: "GL Code", editable: false, visible: false, computed: Forms::Compute::Lookup('items.category_id', '{{record.gl_code}}')
      text :hsn_sac, label: "SAC/HSN", editable: true, visible: true, computed: Forms::Compute::Lookup('items.inventory_line_item_id', '{{record.hsn_sac}}')

      lookup :tds_applicable, visible: true, editable: false,
              can_editable_be_changed: false,
              can_visible_be_changed: false,
              computed: Forms::Compute::Lookup('items.inventory_line_item_id', '{{ record.tds_applicable }}')

      # currency :currency_code, editable: false, visible: false, computed: Forms::Compute::Form("{{ form.currency_code }}")
      number :quantity, label: "Quantity", editable: true, visible: true, required: true, min_value: 1, default_value: 1 # todo - condition

      lookup :unit_of_measurement, label: "Unit of Measurement",
              choices_scope: Choices[:list].(*Unit.all.map{ |v| {id: v.value, name: v.name }}),
              required: true, editable: true, visible: true,
              computed: Forms::Compute::Lookup('items.inventory_line_item_id', '{{record.unit_of_measurement}}')
      
      # dropdown :unit_of_measurement, visible: false, choices_scope: Choices[:list].({id: "KG", value: "KG"})
      amount :rate, label: "Rate",
             can_editable_be_changed: false,
             can_visible_be_changed: false,
             required: true,
             computed: Forms::Compute::Lookup('items.inventory_line_item_id', '{{record.rate}}')

      # gross_amount = rate x quantity
      amount :item_gross_amount, editable: false, visible: false,
             can_visible_be_changed: false,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:item_gross_amount])
      amount :item_gross_amount_converted, editable: false, visible: false,
             can_visible_be_changed: false,
             can_editable_be_changed: false

      # discount # discount percentage
      number :discount, visible: true, editable: true, default_value: 0

      # discount_amount = gross_amount x discount / 100
      amount :item_discount_amount, editable: false, visible: true,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:item_discount_amount])
      amount :item_discount_amount_converted, editable: false, visible: true,
             can_visible_be_changed: false,
             can_editable_be_changed: false

      # taxable_amount = gross_amount - discount_amount
      amount :item_taxable_amount, editable: false, visible: true,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:item_taxable_amount])
      amount :item_taxable_amount_converted, editable: false, visible: true,
             can_visible_be_changed: false,
             can_editable_be_changed: false

      # dropdown :tax_type, label: "Tax Type", choices_scope: Choices[:list].({id: 'IGST', name: "IGST"}, {id: 'CGST+SGST', name: "CGST+SGST"}, {id: 'VAT', name: 'VAT'}), required: false
      
      dropdown :tax_type, label: "Tax Type",
                choices_scope: Choices[:list].(*TaxType.where(country_name: "{{ form.vendor_country }}".downcase ).map{ |t| {id: t.id, name: t.name }}),
                required: true, editable: true, visible: true
      lookup :tax_rate_id, label: "Tax Rate", editable: true, visible: true, choices_scope: Choices[:lookup].('tax_rates'), computed: Forms::Compute::Lookup('items.inventory_line_item_id', '{{record.tax_rate_id}}')

      # tax # tax percentage
      number :tax_percentage, editable: false, visible: true, computed: Forms::Compute::Lookup('items.tax_rate_id', '{{record.rate}}')

      # tax_amount = taxable_amount x tax / 100
      amount :item_tax_amount, editable: false, visible: false,
             can_editable_be_changed: false,
             can_visible_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:item_tax_amount])
      amount :item_tax_amount_converted, editable: false, visible: false,
             can_visible_be_changed: false,
             can_editable_be_changed: false

      amount :item_tds_amount, label: "TDS Amount", editable: false, visible: false,
             can_editable_be_changed: false,
             can_visible_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:item_tds_amount])
      amount :item_tds_amount_converted, editable: false, visible: false,
             can_visible_be_changed: false,
             can_editable_be_changed: false

      amount :item_net_amount, label: "Net Amount", editable: false, visible: true,
             can_editable_be_changed: false,
             can_visible_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:item_net_amount])
      amount :item_net_amount_converted, editable: false, visible: false,
             can_visible_be_changed: false,
             can_editable_be_changed: false

      amount :item_billable_amount, label: "Billable Amount", editable: false, visible: false,
             can_editable_be_changed: false,
             can_visible_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:item_billable_amount])
      amount :item_billable_amount_converted, editable: false, visible: false,
             can_visible_be_changed: false,
             can_editable_be_changed: false
    end
  end

  # INVOICE ITEMS SUMMARY
  section :summary do
    summary :items_summary do
      amount :invoice_gross_amount, editable: false,
             can_editable_be_changed: false,
             can_visible_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:invoice_gross_amount])
      amount :invoice_gross_amount_converted, editable: false, visible: false,
             can_visible_be_changed: false,
             can_editable_be_changed: false

      amount :total_line_item_discount_amount, editable: false,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:total_line_item_discount_amount])

      amount :overall_discount_amount, editable: false,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:overall_discount_amount])

      amount :invoice_discount_amount, label: "Net Discount Amount",
              editable: false, can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:invoice_discount_amount])
      amount :invoice_discount_amount_converted, editable: false, visible: false,
             can_visible_be_changed: false, label: "Net Discount Amount Converted",
             can_editable_be_changed: false

      amount :invoice_taxable_amount, editable: false, visible: false,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:invoice_taxable_amount])
      amount :invoice_taxable_amount_converted, editable: false, visible: false,
             can_editable_be_changed: false,
             can_visible_be_changed: false

      amount :invoice_tax_amount, editable: false,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:invoice_tax_amount])
      amount :invoice_tax_amount_converted, editable: false, visible: false,
             can_visible_be_changed: false,
             can_editable_be_changed: false


      lookup :tds_slab_id, choices_scope: Choices[:lookup].('tds_slabs') # todo - condition when reporting currency is in INR
      number :tds_percentage, internal: true, editable: false, # todo - condition when reporting currency is in INR
             can_editable_be_changed: false,
             computed: Forms::Compute::Lookup('items_summary.tds_slab_id', '{{record.tds}}')

      amount :invoice_tds_amount, editable: false, # todo - condition when reporting currency is in INR
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:invoice_tds_amount])
      amount :invoice_tds_amount_converted, editable: false, visible: false,
             can_visible_be_changed: false,
             can_editable_be_changed: false

      amount :invoice_freight_amount, label: "Freight",
             default_value: 0, visible: true, editable: true
      amount :invoice_freight_amount_converted, editable: false, visible: false,
             can_visible_be_changed: false,
             can_editable_be_changed: false

      amount :invoice_sub_total_amount, editable: false, visible: false,
             can_visible_be_changed: false,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:invoice_sub_total_amount]) # todo - changd name
      amount :invoice_sub_total_amount_converted, editable: false, visible: false,
             can_visible_be_changed: false,
             can_editable_be_changed: false

      amount :invoice_roundoff_amount, visible: true, editable: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:invoice_roundoff_amount]) # todo - changd name
      amount :invoice_roundoff_amount_converted, editable: false, visible: false,
             can_visible_be_changed: false,
             can_editable_be_changed: false

      amount :invoice_total_amount, editable: false, visible: true,
             can_editable_be_changed: false,
             can_visible_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:invoice_total_amount])
      amount :invoice_total_amount_converted, editable: false, visible: false,
             can_visible_be_changed: false,
             can_editable_be_changed: false

      amount :invoice_paid_outside_amount, "Payment Outside Finly",
             default_value: 0, visible: true, editable: true
      amount :invoice_paid_outside_amount_converted, editable: false, visible: false,
             can_visible_be_changed: false,
             can_editable_be_changed: false

      amount :invoice_advance_paid_amount, "Advance Paid",
             default_value: 0, editable: false, visible: true
      amount :invoice_advance_paid_amount_converted, editable: false, visible: false,
             can_visible_be_changed: false,
             can_editable_be_changed: false

      amount :invoice_net_total_amount, label: "Net Total", editable: false,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:invoice_net_total_amount])
      amount :invoice_net_total_amount_converted, editable: false, visible: false,
             can_editable_be_changed: false

      amount :invoice_balance_due, label: "Balance Payable", editable: false,
             can_editable_be_changed: false, visible: true,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:invoice_balance_due])
      amount :invoice_balance_due_converted, editable: false, visible: true,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:invoice_balance_due_converted]),
             can_visible_be_changed: false, can_editable_be_changed: false

      # amount :net_amount, editable: false, computed: Forms::Compute::Form('{{ form.gross_amount | minus: form.discount_amount | plus: form.tax_amount }}')
    end
  end

  # ATTACHMENTS
  section :attachments, associate_custom_fields: true do
    attachment :invoice_attachments, system_field: false
  end
  # If reporting currency & base currency are same, then hide conversion_rate

  # VALIDATIONS
  validation validation_id: "Invoice Date Cannot be Later than Due Date" do
    reference 'due_date'
    error_message "Invoice Due Date must be After Invoice Date"
    rule Rules::Builder['due_date'].lt(entity: "date")
  end

  # CONDITIONS
  condition condition_id: "Policy should not be editable once unless in editable status" do
    reference :entity, :policy_id
    rule Rules::Builder[:invoice_status_id].eq_any(*InwardInvoiceStatus.ids_for(:open).map {|item| {value: item}})
    action :editable, true
    action :required, true
  end


  condition condition_id: "Enable Bank Accounts > Swift / BIC Code for International Vendors" do
    reference :entity, 'vendor_bank_account_swift_code'
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :visible, true
    action :required, true
  end

  condition condition_id: "Disable Vendor Location > No Location for International Vendors" do
    reference :entity, 'gstin_location_id'
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :visible, false
    action :required, false
  end

  condition condition_id: "Disable Vendor Gstin > No Gstin for International Vendors" do
    reference :entity, 'vendor_gstin'
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :visible, false
    action :required, false
  end

  condition condition_id: "Disable Vendor Pan > No Pan for International Vendors" do
    reference :entity, 'vendor_pan'
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :visible, false
    action :required, false
  end

  condition condition_id: "Disable Bank Accounts > IFS Code for International Vendors" do
    reference :entity, 'vendor_bank_account_ifsc'
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :visible, false
    action :required, false
  end

  condition condition_id: "Disable Item Tds Applicable > Tds Applicable for International Vendors" do
    reference :entity, 'items.tds_applicable'
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :visible, false
    action :required, false
  end

  condition condition_id: "Disable Summary TDS Slab > Summary TDS Slab for International Vendors" do
    reference :entity, 'items_summary.tds_slab_id'
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :visible, false
    action :required, false
  end

  condition condition_id: "Disable Summary TDS Percentage > Summary TDS Percentage for International Vendors" do
    reference :entity, 'items_summary.tds_percentage'
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :visible, false
    action :required, false
  end

  condition condition_id: "Disable Summary TDS Amount > TDS Amount for International Vendors" do
    reference :entity, 'items_summary.invoice_tds_amount'
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :visible, false
    action :required, false
  end

  # condition condition_id: "Set Min and Max for discount > Discount Min Max" do
  #   reference :entity, 'accounting_details.discount_type'
  #   rule Rules::Builder[:vendor_country].eq(value: 'percentage')
  #   action min_value: 0
  #   action max_value: 100
  # end

  # condition condition_id: "Disable item department > Item department not for Header Cost Allocation Items" do
  #   reference :entity, 'items.department_id'
  #   rule Rules::Builder[:cost_allocation_items].not_eq(value: 'Header')
  #   action :visible, true
  #   action :required, true
  #   action :editable, true
  # end

  # condition condition_id: "Enable item department > Item Cost Center for Header Cost Allocation Items" do
  #   reference :entity, 'department_id'
  #   rule Rules::Builder[:cost_allocation_items].not_eq(value: 'Header')
  #   action :visible, false
  #   action :required, false
  #   action :editable, false
  # end

  # condition condition_id: "Disable item Cost Center > Item Cost Center not for Header Cost Allocation Items" do
  #   reference :entity, 'items.cost_center_id'
  #   rule Rules::Builder[:cost_allocation_items].not_eq(value: 'Header')
  #   action :visible, true
  #   action :required, true
  #   action :editable, true
  # end

  # condition condition_id: "Enable item Cost Center > Item Cost Center for Header Cost Allocation Items" do
  #   reference :entity, 'cost_center_id'
  #   rule Rules::Builder[:cost_allocation_items].not_eq(value: 'Header')
  #   action :visible, false
  #   action :required, false
  #   action :editable, false
  # end






  # validation validation_id: "Advance Amount cannot be greater than total amount" do
  #   reference 'advance_paid_amount'
  #   error_message "Advance Amount Cannot be Greater Than Invoice Total"
  #   rule Rules::Builder['advance_paid_amount'].gt(entity: "total_amount")
  # end

  # CONDITIONS

  # condition condition_id: "GSTIN Field to be visible when vendor is Indian" do
  #   reference 'entity', 'gstin'
  #   rule Rules::Builder['']
  # end


  # condition condition_id: "Receiving Account Type can only be active if Receiving Account ID is set" do
  #   reference 'entity', 'receiving_account_type'
  #   rule Rules::Builder['receiving_account_id'].present
  #   action :active, true
  # end
  #
  # condition condition_id: 'Disable line item department for header level cost allocation' do
  #   reference 'entity', 'items.department_id'
  #   rule Rules::Builder['cost_allocation_items'].false
  #   action :visible, false
  #   action :editable, false
  # end
  # #
  # condition condition_id: 'Disable line item cost center for header level cost allocation' do
  #   reference 'entity', 'items.cost_center_id'
  #   rule Rules::Builder['cost_allocation_items'].false
  #   action :visible, false
  #   action :editable, false
  # end

  # condition condition_id: 'Enabled header department for header level cost allocation' do
  #   reference 'entity', 'department_id'
  #   rule Rules::Builder['cost_allocation_items'].false
  #   action :visible, true
  #   action :editable, true
  # end
  
  # condition condition_id: 'Enabled header cost_center for header level cost allocation' do
  #   reference 'entity', 'cost_center_id'
  #   rule Rules::Builder['cost_allocation_items'].false
  #   action :visible, true
  #   action :editable, true
  # end

  # condition condition_id: 'Enable line item department for item level cost allocation' do
  #   reference 'entity', 'items.department_id'
  #   rule Rules::Builder['cost_allocation_items'].true
  #   action :visible, true
  #   action :editable, true
  # end
  
  # condition condition_id: 'Enable line item cost center for item level cost allocation' do
  #   reference 'entity', 'items.cost_center_id'
  #   rule Rules::Builder['cost_allocation_items'].true
  #   action :visible, true
  #   action :editable, true
  # end
  
  # condition condition_id: 'Disable header department for item level cost allocation' do
  #   reference 'entity', 'department_id'
  #   rule Rules::Builder['cost_allocation_items'].true
  #   action :visible, false
  #   action :editable, false
  # end
  
  # condition condition_id: 'Disable header cost_center for item level cost allocation' do
  #   reference 'entity', 'cost_center_id'
  #   rule Rules::Builder['cost_allocation_items'].true
  #   action :visible, false
  #   action :editable, false
  # end
  #

  #
  # validation validation_id: :due_date_gteq_invoice_date do
  #   reference 'due_date'
  #   error_message "Due Date cannot be before the invoice date"
  #   rule Rules::Builder['due_date'].lt(entity: "date")
  # end



end
