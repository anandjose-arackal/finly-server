class Docs::P2P::Invoices::NonPo::Form < Forms::API

  model Invoice

  # LIQUID FORMULAE
  LIQUID_FORMULAE = {
      items: {
          item_gross_amount: "{{ row.rate | times: row.quantity | default: 0 | round: 2  }}",
          item_discount_amount: "{% if form.discount_type_id == '1' %}{{ row.item_gross_amount | times: row.discount | divided_by: 100 | default: 0 | round: 2  }}{% else %}{{ row.discount | default: 0 }}{% endif %}",
          item_taxable_amount: "{{ row.item_gross_amount | minus: row.item_discount_amount | default: 0 | round: 2  }}",
          item_tax_amount: "{{ row.item_taxable_amount | times: row.tax_percentage | divided_by: 100 | default: 0 | round: 2  }}",
          item_tds_amount: "{% if row.tds_applicable == true %}{{ row.item_taxable_amount | times: form.tds_percentage | divided_by: 100 | default: 0 | round: 2  }}{% else %}{{ 0 }}{% endif %}",
          item_net_amount: "{{ row.item_taxable_amount | plus: row.item_tax_amount | default: 0 | round: 2  }}",
          item_billable_amount: "{{ row.item_taxable_amount | plus: row.item_tax_amount | minus: row.item_tds_amount | default: 0 | round: 2  }}", # todo - I2P will be different for PO invoice          

          # CONVERTED VALUES
          reporting_item_gross_amount:    "{{ row.item_gross_amount | times: form.conversion_rate | default: 0 | round: 2}}",
          reporting_item_discount_amount: "{{ row.item_discount_amount | times: form.conversion_rate | default: 0 | round: 2}}",
          reporting_item_taxable_amount:  "{{ row.item_taxable_amount | times: form.conversion_rate | default: 0 | round: 2}}",
          reporting_item_tax_amount:      "{{ row.item_tax_amount | times: form.conversion_rate | default: 0 | round: 2  }}",
          reporting_item_tds_amount:      "{{ row.item_tds_amount | times: form.conversion_rate | default: 0 | round: 2  }}",
          reporting_item_net_amount:      "{{ row.item_net_amount | times: form.conversion_rate | default: 0 | round: 2  }}",
          reporting_item_billable_amount: "{{ row.item_billable_amount | times: form.conversion_rate | default: 0 | round: 2  }}"

      },
      # INVOICE SUMMARY
      summary: {
          invoice_gross_amount: "{% assign gross_amount = 0 %}{% for item in form.items %}{% if item._destroy == true %}{% continue %}{% else %}{% assign gross_amount = gross_amount | plus: item.item_gross_amount %}{% endif %}{% endfor %}{{ gross_amount | default: 0 | round: 2 }}",
          total_line_item_discount_amount: "{% assign discount_amount = 0 %}{% for item in form.items %}{% if item._destroy == true %}{% continue %}{% else %}{% assign discount_amount = discount_amount | plus: item.item_discount_amount %}{% endif %}{% endfor %}{{ discount_amount | default: 0 | round: 2 }}",
          overall_discount_amount: "{{ form.overall_discount_amount | default: 0 | round: 2 }}",
          invoice_discount_amount: "{{ form.total_line_item_discount_amount | plus: form.overall_discount_amount | default: 0 | round: 2}}",
          invoice_taxable_amount: "{{ form.invoice_gross_amount | minus: form.invoice_discount_amount | default: 0 | round: 2}}",
          invoice_tax_amount: "{% assign tax_amount = 0 %}{% for item in form.items %}{% if item._destroy == true %}{% continue %}{% else %}{% assign tax_amount = tax_amount | plus: item.item_tax_amount %}{% endif %}{% endfor %}{{ tax_amount  | default: 0 | round: 2}}",
          invoice_tds_amount: "{% assign tds_amount = 0 %}{% for item in form.items %}{% if item._destroy == true %}{% continue %}{% else %}{% assign tds_amount = tds_amount | plus: item.item_tds_amount %}{% endif %}{% endfor %}{{ tds_amount  | default: 0 | round: 2}}",
          invoice_freight_amount: "{{ form.invoice_freight_amount | default: 0 | round: 2}}",
          invoice_sub_total_amount: "{% assign inv_sub_total_amount = form.invoice_gross_amount | minus: form.invoice_discount_amount | plus: form.invoice_tax_amount | plus: form.invoice_freight_amount | minus: form.invoice_tds_amount | round: 2 %}{% if form.rcm_enabled == true  %}{{ inv_sub_total_amount | minus: form.invoice_tax_amount | default: 0 | round: 2}}{% else %}{{ inv_sub_total_amount | default: 0 | round: 2}}{% endif %}",
          # todo - Issue : Roundoff should be automatically calulated everytime user inputs something, even if its the round off itself
          invoice_roundoff_amount: "{% assign amount = form.invoice_sub_total_amount | round %}{% assign amount = amount | minus: form.invoice_sub_total_amount %}{% if form.reporting_currency  != form.base_currency  %}{% assign amount = 0 %}{% endif %}{{ amount | default: 0 | round: 2 }}",
          invoice_total_amount: "{{ form.invoice_sub_total_amount | plus: form.invoice_roundoff_amount | default: 0 | round: 2}}",
          invoice_net_total_amount: "{{ form.invoice_total_amount | minus: form.invoice_paid_outside_amount | default: 0 | round: 2}}",
          # todo - will be shown on top of invoice and needs separate calculation
          # invoice_balance_due: "{{ form.invoice_total_amount | minus: form.invoice_advance_paid_amount | round: 2 }}",          
          invoice_advance_paid_amount: "{{ form.invoice_advance_paid_amount | default: 0 | round: 2}}",
          invoice_balance_due: "{{ form.invoice_total_amount | minus: form.invoice_advance_paid_amount | minus: form.invoice_paid_outside_amount | default: 0 | round: 2}}",
          
          # CONVERTED VALUES
          reporting_invoice_gross_amount: "{{ form.invoice_gross_amount | times: form.conversion_rate | default: 0 | round: 2}}",
          reporting_invoice_discount_amount: "{{ form.invoice_discount_amount | times: form.conversion_rate | default: 0 | round: 2}}",
          reporting_invoice_taxable_amount: "{{ form.invoice_taxable_amount | times: form.conversion_rate | default: 0 | round: 2}}",
          reporting_invoice_tax_amount: "{{ form.invoice_tax_amount | times: form.conversion_rate | default: 0 | round: 2}}",
          reporting_invoice_tds_amount: "{{ form.invoice_tds_amount | times: form.conversion_rate | default: 0 | round: 2}}",
          reporting_invoice_paid_outside_amount: "{{ form.invoice_paid_outside_amount | times: form.conversion_rate | default: 0 | round: 2}}",
          reporting_invoice_freight_amount: "{{ form.invoice_freight_amount | times: form.conversion_rate | default: 0 | round: 2}}",
          reporting_invoice_sub_total_amount: "{{ form.invoice_sub_total_amount | times: form.conversion_rate | default: 0 | round: 2}}",
          reporting_invoice_roundoff_amount: "{% assign amount = form.reporting_invoice_sub_total_amount | round %}{% assign amount = amount | minus: form.reporting_invoice_sub_total_amount %}{% if form.reporting_currency != form.base_currency %}{% assign amount = 0 %}{% endif %}{{ amount | default: 0 | round: 2}}",
          reporting_invoice_total_amount: "{% assign amount = form.reporting_invoice_sub_total_amount | plus: form.reporting_invoice_roundoff_amount %}{% if form.reporting_currency != form.base_currency %}{% assign amount = 0 %}{% endif %}{{ amount | default: 0 | round: 2 }}",
          reporting_invoice_net_total_amount: "{{ form.reporting_invoice_total_amount | minus: form.reporting_invoice_paid_outside_amount | default: 0 | round: 2}}",
          reporting_invoice_advance_paid_amount: "{{ form.invoice_advance_paid_amount | times: form.conversion_rate | default: 0 | round: 2}}",
          reporting_invoice_balance_due: "{{ form.invoice_balance_due | times: form.conversion_rate | default: 0 | round: 2}}"
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
         computed: Forms::Compute::Lookup('payment_term_id', '{{record.days_after | default: 0 }}'),
         visible: false
    
    # can_choices_be_changed: false, default_value: false
    # '{% assign assigne_days = form.payment_term_days | times: 86400 %}{{ form.date | date: "%s" | plus: assigne_days | date: "%d-%m-%Y" }}'
    date :due_date,
      # computed: Forms::Compute::Form('{% assign assigne_days = form.payment_term_days | times: 86400 %}{{ form.date | date: "%s" | plus: assigne_days | date: "%Y-%m-%d" }}'),
      computed: Forms::Compute::Form('{% assign assigne_days = form.payment_term_days | times: 86400 %}{% assign calculated_date = form.date | date: "%s" | plus: assigne_days %}{% assign default_due_date = "now" |date: "%s" | plus: 84600 %}{% if calculated_date < default_due_date %}{{ default_due_date  | date: "%Y-%m-%d" }}{% else %}{{ calculated_date  | date: "%Y-%m-%d" }}{% endif %}'),
      visible: true, required: true, editable: true


    dropdown :cost_allocation_items, choices_scope: Choices[:list].({id: "Header", name: "Header"}, {id: "Line Item", name: "Line Item"}),
             required: true, can_choices_be_changed: false, default_value: 'false'

    date :transaction_service_period_from, label: 'Transaction Service Period (From Date)', editable: true, visible: true
    date :transaction_service_period_to, label: 'Transaction Service Period (To Date)', editable: true, visible: true

  end

  # ACCOUNTING DETAILS
  section :accounting_details, title: "Accounting Details", associate_custom_fields: true do
    lookup :policy_id,
         choices_scope: Choices[:lookup].('policies'),
         #permissions: [:non_po_invoice_initiator]),
         required: true, editable: false
    lookup :department_id, label: "Department", editable: true, visible: true, required: true, choices_scope: Choices[:lookup].('departments') #, editable: false, visible: false
    lookup :cost_center_id, label: "Cost Center", editable: true, visible: true, required: true, choices_scope: Choices[:lookup].('cost_centers')
    dropdown :discount_type_id, label: "Discount Type", editable: true, visible: true, required: true, choices_scope: Choices[:list].({id: 1, name: 'Percentage'}, {id: 2, name: 'Amount'} ), default_value: 'Percentage'
    # lookup :tax_type_id, label: "Tax Type", editable: true, visible: true, choices_scope: Choices[:lookup].('tax_types')
    dropdown :tax_type_id, label: "Tax Type", editable: true, visible: true, choices_scope: Choices[:list].(*TaxType.all.map{ |v| {id: v.id, name: v.name }})
    
    date :conversion_date, label: "Conversion Date", editable: false, visible: true,
         computed: Forms::Compute::Form('{{form.date}}')

    currency :reporting_currency, label: "Reporting Currency", editable: false, visible: true,
            can_editable_be_changed: false # todo populate with system base currency

    currency :base_currency, label: "Base Currency", visible: true, editable: true

    switch :retrieve_conversion_rate, label: "Auto Populate Conversion Rate", default_value: true, visible: false
    number :conversion_rate, editable: true, format: 'decimal', default_value: 1, visible: true
    # date :transaction_service_period_from, label: 'Transaction Period From'
    # date :transaction_service_period_to, label: 'Transaction Period To'
    large_text :narration, label: "Narration"
  end

  # VENDOR DETAILS
  section :vendor_details, title: "Vendor Details", associate_custom_fields: true do
    lookup :vendor_id, label: "Vendor", choices_scope: Choices[:lookup].('vendors'), required: true, editable: false,
           can_editable_be_changed: false, can_be_disabled: false, can_required_be_changed: false, can_visible_be_changed: false
    
    lookup :vendor_trade_name, label: 'Vendor Trade Name', editable: false, visible: true, computed: Forms::Compute::Lookup('vendor_id', '{{record.trade_name}}')
    text :vendor_country, editable: false, visible: true
    
    text :vendor_sequence_id, "Vendor ID", editable: false, computed: Forms::Compute::Lookup('vendor_id', '{{record.vendor_id}}')
    
    lookup :gstin_location_id, label: 'Vendor Location', choices_scope: Choices[:lookup].('vendor_locations'), # todo - condition to hide for international
          filters: Rules::Builder[:vendor_id].eq(entity: :vendor_id)
    text :vendor_gstin, "Vendor GSTIN", editable: false, computed: Forms::Compute::Lookup('gstin_location_id', '{{record.gstin}}') # todo - condition
    text :vendor_pan, "Vendor PAN", editable: false # todo - add condition
    lookup :receiving_account_id, label: "Vendor Account", choices_scope: Choices[:lookup].('vendor_bank_accounts'),
          filters: Rules::Builder[:account_owner_id].eq(entity: 'vendor_id').and(Rules::Builder[:account_owner_type].eq(value: 'YesBankVendor')),
          editable: true, visible: true, required: true
    
    text :receiving_account_type, visible: false, internal: true, editable: false, computed: Forms::Compute::Form('BankAccount')
    switch :rcm_enabled, label: "RCM Enabled", editable: true, visible: true, computed: Forms::Compute::Lookup('vendor_id', '{{record.rcm_enabled}}'), default_value: true

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
           can_visible_be_changed: false, visible: false,
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

      dropdown :unit_of_measurement, label: "Unit of Measurement",
              choices_scope: Choices[:list].(*Unit.all.map{ |v| {id: v.value, name: v.name }}),
              required: true, editable: true, visible: true,
              computed: Forms::Compute::Lookup('items.inventory_line_item_id', '{{record.unit_of_measurement}}')
      
      number :item_rate,
           label: "Item Rate",
           computed: Forms::Compute::Lookup('items.inventory_line_item_id', '{{ record.rate | default: 0}}'),
           visible: true

      amount :rate, label: "Rate",
             can_editable_be_changed: false,
             can_visible_be_changed: false,
             required: true, visible: true, editable: true,
             computed: Forms::Compute::Form('{{ items.item_rate | divided_by: form.conversion_rate | round: 2 }}')
             # computed: Forms::Compute::Lookup('items.inventory_line_item_id', '{{ record.rate | default: 0}}')

      # gross_amount = rate x quantity
      amount :item_gross_amount, label: 'Item Gross Amount(Base Currency)', editable: false, visible: false,
             can_visible_be_changed: false,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:item_gross_amount])

      amount :reporting_item_gross_amount, label: 'Item Gross Amount(Reporting Currency)', editable: false, visible: false,
             can_visible_be_changed: false,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:reporting_item_gross_amount])

      # discount # discount percentage
      number :discount, visible: true, editable: true, default_value: 0

      # discount_amount = gross_amount x discount / 100
      amount :item_discount_amount, label: 'Item Discount Amount(Base Currency)', editable: false, visible: true,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:item_discount_amount])

      amount :reporting_item_discount_amount, label: 'Item Discount Amount(Reporting Currency)', editable: false, visible: false,
             can_visible_be_changed: false,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:reporting_item_discount_amount])

      # taxable_amount = gross_amount - discount_amount
      amount :item_taxable_amount, label: 'Item Taxable Amount(Base Currency)', editable: false, visible: true,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:item_taxable_amount])

      amount :reporting_item_taxable_amount, label: 'Item Taxable Amount(Reporting Currency)', editable: false, visible: false,
             can_visible_be_changed: false,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:reporting_item_taxable_amount])
      
      lookup :tax_rate_id, label: "Tax Rate", editable: true, visible: true, choices_scope: Choices[:lookup].('tax_rates'), computed: Forms::Compute::Lookup('items.inventory_line_item_id', '{{record.tax_rate_id}}')

      # tax # tax percentage
      number :tax_percentage, editable: false, visible: true, computed: Forms::Compute::Lookup('items.tax_rate_id', '{{record.rate}}')

      # tax_amount = taxable_amount x tax / 100
      amount :item_tax_amount, label: 'Item Tax Amount(Base Currency)', editable: false, visible: true,
             can_editable_be_changed: false,
             can_visible_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:item_tax_amount])

      amount :reporting_item_tax_amount, label: 'Item Tax Amount(Reporting Currency)', editable: false, visible: false,
             can_visible_be_changed: false,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:reporting_item_tax_amount])

      amount :item_tds_amount, label: 'Tds Amount(Base Currency)', editable: false, visible: true,
             can_editable_be_changed: false,
             can_visible_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:item_tds_amount])

      amount :reporting_item_tds_amount, label: 'Tds Amount(Reporting Currency)', editable: false, visible: false,
             can_visible_be_changed: false,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:reporting_item_tds_amount])

      amount :item_net_amount, label: "Net Amount(Base Currency)", editable: false, visible: true,
             can_editable_be_changed: false,
             can_visible_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:item_net_amount])

      amount :reporting_item_net_amount, label: "Net Amount(Reporting Currency)", editable: false, visible: false,
             can_visible_be_changed: false,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:reporting_item_net_amount])

      amount :item_billable_amount, label: "Billable Amount(Base Currency)", editable: false, visible: false,
             can_editable_be_changed: false,
             can_visible_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:item_billable_amount])

      amount :reporting_item_billable_amount, label: "Billable Amount(Reporting Currency)", editable: false, visible: false,
             can_visible_be_changed: false,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:reporting_item_billable_amount])
    end
  end

  # INVOICE ITEMS SUMMARY
  section :summary do
    summary :items_summary do
      amount :invoice_gross_amount, label: 'Invoice Gross Amount(Base Currency)', editable: false, visible: true,
             can_editable_be_changed: false,
             can_visible_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:invoice_gross_amount])

      amount :reporting_invoice_gross_amount, label: 'Invoice Gross Amount(Reporting Currency)', editable: false, visible: false,
             can_visible_be_changed: false,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_invoice_gross_amount])

      amount :total_line_item_discount_amount, label: 'Total LineItem Discount Amount', editable: false, visible: true,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:total_line_item_discount_amount])

      amount :overall_discount_amount, label: 'Overall Discount Amount', editable: true, visible: true,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:overall_discount_amount])

      amount :invoice_discount_amount, label: "Net Discount Amount( Base Currency )", visible: true,
              editable: false, can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:invoice_discount_amount])

      amount :reporting_invoice_discount_amount, editable: false, visible: false,
             can_visible_be_changed: false, label: "Net Discount Amount( Reporting Currency )",
             can_editable_be_changed: false, 
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_invoice_discount_amount])

      amount :invoice_taxable_amount, label: 'Invoice Taxable Amount(Base Currency)', editable: false, visible: true,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:invoice_taxable_amount])

      amount :reporting_invoice_taxable_amount, label: 'Invoice Taxable Amount(Reporting Currency)', editable: false, visible: false,
             can_editable_be_changed: false,
             can_visible_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_invoice_taxable_amount])

      amount :invoice_tax_amount, label: 'Invoice Tax Amount(Base Currency)', editable: false, visible: true,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:invoice_tax_amount])

      amount :reporting_invoice_tax_amount, label: 'Invoice Tax Amount(Reporting Currency)', editable: false, visible: false,
             can_visible_be_changed: false,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_invoice_tax_amount])

      lookup :tds_slab_id, choices_scope: Choices[:lookup].('tds_slabs'), visible: true # todo - condition when reporting currency is in INR
      
      number :tds_percentage, internal: true, editable: false, visible: true, # todo - condition when reporting currency is in INR
             can_editable_be_changed: false,
             computed: Forms::Compute::Lookup('items_summary.tds_slab_id', '{{record.tds}}')

      amount :invoice_tds_amount, label: 'Invoice Tds Amount(Base Currency)', editable: false, visible: true, # todo - condition when reporting currency is in INR
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:invoice_tds_amount])
      
      amount :reporting_invoice_tds_amount, label: 'Invoice Tds Amount(Reporting Currency)', editable: false, visible: false,
             can_visible_be_changed: false,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_invoice_tds_amount])

      amount :invoice_freight_amount, label: "Freight(Base Currency)",
             default_value: 0, visible: true, editable: true,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:invoice_freight_amount])

      amount :reporting_invoice_freight_amount, label: "Freight(Reporting Currency)", editable: false, visible: false,
             can_visible_be_changed: false,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_invoice_freight_amount])

      amount :invoice_sub_total_amount, label: 'Invoice SubTotal Amount(Base Currency)', editable: false, visible: false,
             can_visible_be_changed: false,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:invoice_sub_total_amount]) # todo - changd name

      amount :reporting_invoice_sub_total_amount, label: 'Invoice SubTotal Amount(Reporting Currency)', editable: false, visible: false,
             can_visible_be_changed: false,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_invoice_sub_total_amount]) # todo - changd name

      amount :invoice_roundoff_amount, label: 'Invoice Roundoff Amount(Base Currency)', visible: true, editable: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:invoice_roundoff_amount]) # todo - changd name

      amount :reporting_invoice_roundoff_amount, label: 'Invoice Roundoff Amount(Reporting Currency)', editable: false, visible: false,
             can_visible_be_changed: false,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_invoice_roundoff_amount]) # todo - changd name

      amount :invoice_total_amount, label: 'Invoice Total Amount(Base Currency)', editable: false, visible: true,
             can_editable_be_changed: false,
             can_visible_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:invoice_total_amount])

      amount :reporting_invoice_total_amount, label: 'Invoice Total Amount(Reporting Currency)', editable: false, visible: false,
             can_visible_be_changed: false,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_invoice_total_amount])

      amount :invoice_paid_outside_amount, label: "Payment Outside Finly(Base Currency)",
             default_value: 0, visible: true, editable: true

      amount :reporting_invoice_paid_outside_amount, label: "Payment Outside Finly(Reporting Currency)", editable: false, visible: false,
             can_visible_be_changed: false,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_invoice_paid_outside_amount])

      amount :invoice_net_total_amount, label: "Net Total(Base Currency)", editable: false, visible: true,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:invoice_net_total_amount])
      
      amount :reporting_invoice_net_total_amount, label: "Net Total(Reporting Currency)", editable: false, visible: true,
             can_editable_be_changed: false, 
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_invoice_net_total_amount])

      amount :invoice_advance_paid_amount, label: "Amount Paid / Advance(Base Currency)",
             default_value: 0, editable: false, visible: true,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:invoice_advance_paid_amount])

      amount :reporting_invoice_advance_paid_amount, label: "Amount Paid / Advance(Reporting Currency)", editable: false, visible: false,
             can_visible_be_changed: false,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_invoice_advance_paid_amount])

      amount :invoice_balance_due, label: "Balance Payable(Base Currency)", editable: false,
             can_editable_be_changed: false, visible: true,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:invoice_balance_due])

      amount :reporting_invoice_balance_due, label: "Balance Payable(Reporting Currency)", editable: false, visible: true,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_invoice_balance_due]),
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

  # condition condition_id: "Disable Item Tds Applicable > Tds Applicable for International Vendors" do
  #   reference :entity, 'items.tds_applicable'
  #   rule Rules::Builder[:vendor_country].not_eq(value: 'India')
  #   action :visible, false
  #   action :required, false
  # end

  # condition condition_id: "Disable Summary TDS Slab > Summary TDS Slab for International Vendors" do
  #   reference :entity, 'items_summary.tds_slab_id'
  #   rule Rules::Builder[:vendor_country].not_eq(value: 'India')
  #   action :visible, false
  #   action :required, false
  # end

  # condition condition_id: "Disable Summary TDS Percentage > Summary TDS Percentage for International Vendors" do
  #   reference :entity, 'items_summary.tds_percentage'
  #   rule Rules::Builder[:vendor_country].not_eq(value: 'India')
  #   action :visible, false
  #   action :required, false
  # end

  # condition condition_id: "Disable Summary TDS Amount > TDS Amount for International Vendors" do
  #   reference :entity, 'items_summary.invoice_tds_amount'
  #   rule Rules::Builder[:vendor_country].not_eq(value: 'India')
  #   action :visible, false
  #   action :required, false
  # end

  condition condition_id: "Disable RCM for International > Rcm for International Vendors" do
    reference :entity, 'rcm_enabled'
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :visible, false
  end

  condition condition_id: "Hide Conversion Rate Conversion > Conversion Rate for different currency" do
    reference :entity, 'items_summary.reporting_invoice_net_total_amount'
    rule Rules::Builder[:reporting_currency].eq(entity: :base_currency)
    action :visible, false
  end

  # condition condition_id: "Hide Conversion Rate > Conversion Rate for different currency" do
  #   reference :entity, 'conversion_rate'
  #   rule Rules::Builder[:reporting_currency].eq(entity: :base_currency)
  #   action :visible, false
  # end

  condition condition_id: "Disable item department > Item department not for Header Cost Allocation Items" do
    reference :entity, 'items.department_id'
    rule Rules::Builder[:cost_allocation_items_value].not_eq(value: 'Header')
    action :visible, true
    action :required, true
    action :editable, true
  end

  condition condition_id: "Enable item department > Item Cost Center for Header Cost Allocation Items" do
    reference :entity, 'department_id'
    rule Rules::Builder[:cost_allocation_items_value].not_eq(value: 'Header')
    action :visible, false
    action :required, false
    action :editable, false
  end

  condition condition_id: "Disable item Cost Center > Item Cost Center not for Header Cost Allocation Items" do
    reference :entity, 'items.cost_center_id'
    rule Rules::Builder[:cost_allocation_items_value].not_eq(value: 'Header')
    action :visible, true
    action :required, true
    action :editable, true
  end

  condition condition_id: "Enable item Cost Center > Item Cost Center for Header Cost Allocation Items" do
    reference :entity, 'cost_center_id'
    rule Rules::Builder[:cost_allocation_items_value].not_eq(value: 'Header')
    action :visible, false
    action :required, false
    action :editable, false
  end

  condition condition_id: "Hide Roundoff for different currency" do
    reference :entity, 'items_summary.invoice_roundoff_amount'
    rule Rules::Builder[:reporting_currency].not_eq(entity: :base_currency)
    action :visible, false
  end

  condition condition_id: "Hide Reporting Roundoff for different currency" do
    reference :entity, 'items_summary.reporting_invoice_roundoff_amount'
    rule Rules::Builder[:reporting_currency].not_eq(entity: :base_currency)
    action :visible, false
  end

  condition condition_id: "Hide Reporting Invoice Total for different currency" do
    reference :entity, 'items_summary.reporting_invoice_total_amount'
    rule Rules::Builder[:reporting_currency].not_eq(entity: :base_currency)
    action :visible, false
  end

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