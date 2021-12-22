class Docs::P2P::PurchaseOrders::Form < Forms::API

  model PurchaseOrder
  label 'PurchaseOrders'

  meta ->(record) {
    {
      created_by: {
        id: record.user.id,
        name: record.user.name,
        email: record.user.email
      },
      company_country_id: record.company.country_id.to_s
    }
  }

  # LIQUID FORMULAE
  LIQUID_FORMULAE = {
    items: {
      item_gross_amount: "{{ row.rate | times: row.quantity | default: 0 | round: 2  }}",
      item_discount_amount:  "{% if form.discount_type_id == 1 %}{{ row.item_gross_amount | times: row.discount | divided_by: 100.00 | default: 0 | round: 2  }}{% else %}{{ row.discount | default: 0 }}{% endif %}",
      item_taxable_amount: "{{ row.item_gross_amount | minus: row.item_discount_amount | default: 0 | round: 2  }}",
      item_tax_amount: "{{ row.item_taxable_amount | times: row.tax_percentage | divided_by: 100.00 | default: 0 | round: 2  }}",
      item_net_amount: "{{ row.item_taxable_amount | plus: row.item_tax_amount | default: 0 | round: 2 | at_least: 0 }}",
        
      # CONVERTED VALUES
      reporting_item_gross_amount: "{{ row.item_gross_amount | times: form.conversion_rate | default: 0 | round: 2}}",
      reporting_item_discount_amount: " {{ row.item_discount_amount | times: form.conversion_rate | default: 0 | round: 2}}",
      reporting_item_taxable_amount: "{{ row.item_taxable_amount | times: form.conversion_rate | default: 0 | round: 2}}",
      reporting_item_tax_amount: "{{ row.item_tax_amount | times: form.conversion_rate | default: 0 | round: 2  }}",
      reporting_item_net_amount: "{{ row.item_net_amount | times: form.conversion_rate | default: 0 | round: 2 | at_least: 0  }}",
    },

    # PURCHASE ORDER SUMMARY
    summary: {
      po_gross_amount: "{% assign gross_amount = 0 %}{% for item in form.items %}{% if item._destroy == true %}{% continue %}{% else %}{% assign gross_amount = gross_amount | plus: item.item_gross_amount %}{% endif %}{% endfor %}{{ gross_amount | default: 0 | round: 2 }}",
      po_discount_amount: "{% assign discount_amount = 0 %}{% for item in form.items %}{% if item._destroy == true %}{% continue %}{% else %}{% assign discount_amount = discount_amount | plus: item.item_discount_amount %}{% endif %}{% endfor %}{{ discount_amount | default: 0 | round: 2 }}",
      po_tax_amount: "{% assign tax_amount = 0 %}{% for item in form.items %}{% if item._destroy == true %}{% continue %}{% else %}{% assign tax_amount = tax_amount | plus: item.item_tax_amount %}{% endif %}{% endfor %}{{ tax_amount  | default: 0 | round: 2}}",
      po_taxable_amount: "{{ form.po_gross_amount | minus: form.po_discount_amount | default: 0 | round: 2}}",
      
      # NET AMOUNT
      po_sub_total_amount: "{% assign po_sub_total_amount = form.po_gross_amount | minus: form.po_discount_amount | plus: form.po_tax_amount | round: 2 %}{{ po_sub_total_amount | default: 0 | round: 2 }}",
      po_roundoff_amount: "{% assign net_total_amount = form.po_sub_total_amount %}{% assign round_amount = net_total_amount | round %}{% assign amount = round_amount | minus: net_total_amount %}{% if form.base_currency_id == '1' and form.reporting_currency_id == '1' %}{{ amount | default: 0 | round: 2 }}{% else %}{{ 0 }}{% endif %}",
      po_total_amount: "{{ form.po_sub_total_amount | plus: form.po_roundoff_amount | default: 0 | round: 2}}",
      po_balance_due: "{{ form.po_total_amount | default: 0 | round: 2}}",
      

      #Advance Calculation
      po_requested_advance_amount: "{{ form.po_requested_advance_amount | default: 0 | round: 2}}",
      po_advance_tds_amount: "{{ form.po_requested_advance_amount | times: form.po_advance_tds_percentage | divided_by: 100.00 | default: 0 | ceil }}",
      # find the max amount on which tds is applicable. 
      # check the the po_requested_advance_amount is less than max_amount then apply tds on po_requested_advance_amount else apply tds on max_applicable_amount
      # po_advance_tds_amount: "{% assign max_tds_applicable_amount = 0 %}{% for item in form.items %}{% if item._destroy == true %}{% continue %}{% elsif item.tds_applicable == 'true' %}{% assign max_tds_applicable_amount = max_tds_applicable_amount | plus: item.item_tax_amount %}{% endif %}{% endfor %}{% if form.po_requested_advance_amount <= max_tds_applicable_amount  %}{{ form.po_requested_advance_amount | times: form.po_advance_tds_percentage | default: 0 | ceil }}{% else  %}{{ max_tds_applicable_amount | times: form.po_advance_tds_percentage | default: 0 | ceil }}{% endif %}",
      # po_advance_tds_amount: "
      # {% assign max_tds_applicable_amount = 0 %}
      # {% for item in form.items %}
      #   {% if item._destroy == true %}
      #     {% continue %}
      #   {% elsif item.tds_applicable == 'true' %}
      #     {% assign max_tds_applicable_amount = max_tds_applicable_amount | plus: item.item_tax_amount %}
      #   {% endif %}
      # {% endfor %}
      # {% if form.po_requested_advance_amount <= max_tds_applicable_amount  %}
      #   {{ form.po_requested_advance_amount | times: form.po_advance_tds_percentage | default: 0 | ceil }}
      # {% else  %}
      #   {{ max_tds_applicable_amount | times: form.po_advance_tds_percentage | default: 0 | ceil }}
      # {% endif %}",
      po_advance_amount: "{{ form.po_requested_advance_amount | minus: form.po_advance_tds_amount | default: 0 | round: 2 }}",


      # CONVERTED VALUES
      reporting_po_gross_amount: "{{ form.po_gross_amount | times: form.conversion_rate | default: 0 | round: 2}}",
      reporting_po_discount_amount: "{{ form.po_discount_amount | times: form.conversion_rate | default: 0 | round: 2}}",
      reporting_po_taxable_amount: "{{ form.po_taxable_amount | times: form.conversion_rate | default: 0 | round: 2}}",
      reporting_po_tax_amount: "{{ form.po_tax_amount | times: form.conversion_rate | default: 0 | round: 2}}",
      reporting_po_sub_total_amount: "{{ form.po_sub_total_amount | times: form.conversion_rate | default: 0 | round: 2}}",
      reporting_po_roundoff_amount: "{{ form.po_roundoff_amount | times: form.conversion_rate | default: 0 | round: 2}}", # This is wrong calculation need to correct it later
      reporting_po_total_amount: "{{ form.po_total_amount | times: form.conversion_rate | default: 0 | round: 2}}",
      reporting_po_balance_due: "{{ form.po_balance_due | times: form.conversion_rate | default: 0 | round: 2}}",

      # Advance Calculation
      reporting_po_requested_advance_amount: "{{ form.po_requested_advance_amount | times: form.conversion_rate | default: 0 | round: 2}}",
      reporting_po_advance_tds_amount: "{{ form.po_advance_tds_amount | times: form.conversion_rate | default: 0 | round: 2}}",
      reporting_po_advance_amount: "{{ form.po_advance_amount | times: form.conversion_rate | default: 0 | round: 2}}",
    }
  }

  # PURCHASE ORDER STATUS
  section :status do
    lookup :purchase_order_status_id,
           choices_scope: Choices[:lookup].('purchase_order_statuses'),
           required: false, editable: false,
           default_value: PurchaseOrderStatus.id_for(:open),
           can_editable_be_changed: false
    large_text :procurement_term_text, visible: false
    number :procurement_term_id, visible: false 
  end

  # PURCHASE ORDER DETAILS
  section :purchase_order_details, title: "Order Details", associate_custom_fields: true do
    auto_number :po_number,
                label: "Sequence Number", editable: false,
                sequence: { prefix: "PO-", start_at: '00001' }

    date :created_at,
         label: "Purchase Order Date",
         computed: Forms::Compute::Form('{{ form.created_at  | date: "%Y-%m-%d" }}'),
         required: true, editable: false

    lookup :payment_term_id,
           choices_scope: Choices[:lookup].('payment_terms'),
           label: "Payment Term",
           visible: true, required: true, editable: true

    number :payment_term_days,
           label: "Payment Term Days",
           computed: Forms::Compute::Lookup('payment_term_id', '{{record.days_after | default: 0 }}'),
           visible: false

    date :delivery_date,
         label: "Due Date",
         computed: Forms::Compute::Form('{% assign assigne_days = form.payment_term_days | times: 86400 %}{% assign calculated_date = form.created_at | date: "%s" | plus: assigne_days %}{{ calculated_date  | date: "%Y-%m-%d" }}'),
         visible: true, required: true, editable: false

    switch :cost_allocation_items, label: 'Cost Allocation (Item Level)', required: true, default_value: false
  end

  # ACCOUNTING DETAILS
  section :accounting_details, title: "Accounting Details", associate_custom_fields: true do
    lookup :policy_id, choices_scope: Choices[:lookup].('policies', permissions: [:purchase_order_initiator]), required: true, editable: false
    lookup :department_id, label: "Department", editable: true, visible: true, required: true, choices_scope: Choices[:lookup].('departments', assignments: { form: true })
    lookup :cost_center_id, label: "Cost Center", editable: true, visible: true, required: true, choices_scope: Choices[:lookup].('cost_centers')
    dropdown :discount_type_id, label: "Discount Type", editable: false, visible: true, required: true, choices_scope: Choices[:list].({ id: "1", name: 'Percentage' }, { id: "2", name: 'Amount' }), default_value: 1
    dropdown :gst_type_id, label: "Tax Type", editable: true, visible: true, choices_scope: Choices[:list].(*TaxType.all.map { |v| { id: v.id, name: v.name } })

    date :conversion_date, label: "Conversion Date", editable: true, visible: true, triggers: {on_change: {lookup_details: [:base_currency_id]},on_compute: {lookup_details: [:base_currency_id]}}#, computed: Forms::Compute::Form('{{form.created_at}}')
    lookup :reporting_currency_id, label: "Reporting Currency", choices_scope: Choices[:lookup].('currencies'), visible: true, editable: false, can_editable_be_changed: false
    lookup :base_currency_id, label: "Base Currency", choices_scope: Choices[:lookup].('currencies'), visible: true, editable: true
    # switch :retrieve_conversion_rate, label: "Auto Populate Conversion Rate", default_value: true, visible: false
    number :conversion_rate, editable: true, format: 'decimal', max_decimal_places: 5, default_value: 1, computed: Forms::Compute::Lookup('base_currency_id', '{{ record.currency_conversion_rate }}', assignments: {conversion_date: "{{form.conversion_date}}", to_currency: "{{form.reporting_currency_id}}"}), visible: true
  end

  # VENDOR DETAILS
  section :vendor_details, title: "Vendor Details", associate_custom_fields: true do
    lookup :vendor_id, label: "Vendor", choices_scope: Choices[:lookup].('vendors'), required: true, editable: false,
           can_editable_be_changed: false, can_be_disabled: false, can_required_be_changed: false, can_visible_be_changed: false

    lookup :vendor_trade_name, label: 'Vendor Trade Name', editable: false, visible: true, computed: Forms::Compute::Lookup('vendor_id', '{{record.business_name}}', assignments: { created_by_id: "{{meta.user_id}}" })
    lookup :vendor_country_id, editable: false, visible: true, choices_scope: Choices[:lookup].('countries')

    text :vendor_sequence_id, "Vendor ID", editable: false, computed: Forms::Compute::Lookup('vendor_id', '{{record.vendor_id}}')
    lookup :gstin_location_id, label: 'Vendor Location', choices_scope: Choices[:lookup].('vendor_locations'), # todo - condition to hide for international
           filters: Rules::Builder[:vendor_id].eq(entity: :vendor_id)
    text :vendor_gstin, "Vendor GSTIN", editable: false, computed: Forms::Compute::Lookup('gstin_location_id', '{{record.gstin}}') # todo - condition
    text :vendor_pan, "Vendor PAN", editable: false # todo - add condition

    lookup :bank_account_id, label: "Bank Account", choices_scope: Choices[:lookup].('vendor_bank_accounts'),
           filters: Rules::Builder[:account_owner_id].eq(entity: 'vendor_id').and(Rules::Builder[:account_owner_type].eq(value: 'YesBankVendor')),
           editable: true, visible: true, required: true

    text :vendor_poc_name, label: 'Poc Name', visible: true, editable: false, can_editable_be_changed: false,
           computed: Forms::Compute::Lookup('gstin_location_id', '{{record.poc_name}}')
    text :vendor_poc_email, label: 'Poc Email', visible: true, editable: false, can_editable_be_changed: false,
           computed: Forms::Compute::Lookup('gstin_location_id', '{{record.poc_email}}')
    text :vendor_poc_mobile_number, label: 'Poc Mobile Number', visible: true, editable: false, can_editable_be_changed: false,
           computed: Forms::Compute::Lookup('gstin_location_id', '{{record.poc_mobile_number}}')

    # need to add these fields as system fields
    text :vendor_bank_account_number, editable: false, can_editable_be_changed: false, computed: Forms::Compute::Lookup('bank_account_id', '{{record.account_number}}')
    text :vendor_bank_account_ifsc, editable: false, required: true, can_editable_be_changed: false, computed: Forms::Compute::Lookup('bank_account_id', '{{record.ifsc}}')
    text :vendor_bank_account_swift_code, editable: false, visible: false, required: false, can_editable_be_changed: false, computed: Forms::Compute::Lookup('bank_account_id', '{{record.swift_code}}')
  end

  # BILLING ADDRESS
  section :billing_address do
    lookup :location_id, label: 'Company Address', choices_scope: Choices[:lookup].('locations', assignments: { form: true }),
           filters: Rules::Builder['billable_location'].true, required: true
    text :billing_address_name, editable: false, computed: Forms::Compute::Lookup('location_id', '{{record.name}}')
    text :billing_address_gstin, editable: false, computed: Forms::Compute::Lookup('location_id', '{{record.gstin}}')
    large_text :billing_address, computed: Forms::Compute::Lookup('location_id', '{{record.address}}')
  end

  # SHIPPING ADDRESS
  section :shipping_address do
    lookup :delivery_location_id, label: 'Delivery Address', choices_scope: Choices[:lookup].('locations', assignments: { form: true }),
           filters: Rules::Builder['shippable_location'].true, required: true
    text :shipping_address_name, editable: false, computed: Forms::Compute::Lookup('delivery_location_id', '{{record.name}}')
    text :shipping_address_gstin, editable: false, computed: Forms::Compute::Lookup('delivery_location_id', '{{record.gstin}}')
    large_text :shipping_address, computed: Forms::Compute::Lookup('delivery_location_id', '{{record.address}}')
  end

  # PURCHASE ORDER ITEMS
  section :items, associate_custom_fields: true do
    table :items, min_items: 1, populate_if_empty: PurchaseOrderItem do
      number :id, visible: false, editable: false, internal: true, can_visible_be_changed: false, can_editable_be_changed: false

      lookup :inventory_line_item_id, label: "Item",
             can_visible_be_changed: false, can_editable_be_changed: false,
             choices_scope: Choices[:lookup].('items'),
             required: true, editable: true, visible: true
            
      text :purchase_request_item_id, visible: false, editable: false, choices_scope: Choices[:lookup].('purchase_requests')

      text :description, editable: false, can_editable_be_changed: false, can_visible_be_changed: false,
          visible: false, computed: Forms::Compute::Lookup('items.inventory_line_item_id', '{{record.description}}')

      text :pr_number, label: "PR Number", editable: false, visible: false,
              computed: Forms::Compute::Lookup('items.purchase_request_item_id', "{{record.pr_number}}")

      text :comment, label: "Narration"
      text :item_number, label: "Item Code", editable: false, 
        computed: Forms::Compute::Lookup('items.inventory_line_item_id', '{{record.item_number}}')

      lookup :product_type_id, label: "Product Type", choices_scope: Choices[:enum].(ProductType), computed: Forms::Compute::Lookup('items.inventory_line_item_id', '{{record.product_type_id}}'), editable: false, required: true, visible: true

      lookup :items_department_id, label: "Department", editable: false, visible: false, required: false, choices_scope: Choices[:lookup].('departments')
      lookup :items_cost_center_id, label: "Cost Center", editable: false, visible: false, required: false, choices_scope: Choices[:lookup].('cost_centers')

      lookup :category_id, label: "Category", required: true, visible: true, editable: true, choices_scope: Choices[:lookup].('categories'), computed: Forms::Compute::Lookup('items.inventory_line_item_id', '{{record.category_id}}')

      # Prakash implemented this with items.category but for some reason it always return '' even if value is present in db
      text :gl_code, label: "GL Code", editable: false, visible: true, 
          computed: Forms::Compute::Lookup('items.inventory_line_item_id', '{{record.gl_code}}')
      
      text :hsn_sac, label: "HSN/SAC", editable: true, visible: true,
        computed: Forms::Compute::Lookup('items.inventory_line_item_id', '{{record.hsn_sac}}')

      lookup :tds_applicable, visible: true, editable: false, can_editable_be_changed: false, can_visible_be_changed: false, 
             choices_scope: Choices[:list].({ id: true, name: 'true' }, { id: false, name: 'false' }),
             computed: Forms::Compute::Lookup('items.inventory_line_item_id', '{{ record.tds_applicable }}')

      number :quantity, label: "Quantity", editable: true, visible: true, required: true, min_value: 1, default_value: 1 # todo - condition

      dropdown :unit_of_measurement, label: "Unit of Measurement",
               choices_scope: Choices[:list].(*Unit.all.map { |v| { id: v.value, name: v.name } }),
               required: true, editable: true, visible: true,
               computed: Forms::Compute::Lookup('items.inventory_line_item_id', '{{record.unit_of_measurement}}')

      amount :item_rate, label: "Item Rate (Reporting Currency)", visible: true, editable: false,
             computed: Forms::Compute::Form('{{ row.rate | times: form.conversion_rate | round: 2 }}')

      amount :rate, label: "Rate (Base Currency)",
             can_editable_be_changed: false, can_visible_be_changed: false,
             required: true, visible: true, editable: true,
             computed: Forms::Compute::Lookup('items.inventory_line_item_id', '{{ record.rate_in_base_currency | default: 0 | round: 2 }}', assignments: {conversion_date: "{{form.conversion_date}}", base_currency_id: "{{form.base_currency_id}}", reporting_currency_id: "{{form.reporting_currency_id}}", conversion_rate: "{{form.conversion_rate}}"})

      # # gross_amount = rate x quantity
      amount :item_gross_amount, label: 'Item Gross Amount', editable: false, visible: true,
             can_visible_be_changed: false, can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:item_gross_amount])

      amount :reporting_item_gross_amount, label: 'Item Gross Amount(Reporting Currency)', editable: false, visible: true,
             can_visible_be_changed: false, can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:reporting_item_gross_amount])

      number :discount, visible: true, editable: true, default_value: 0

      amount :item_discount_amount, label: 'Item Discount Amount', editable: false, visible: false,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:item_discount_amount])

      amount :reporting_item_discount_amount, label: 'Item Discount Amount(Reporting Currency)', editable: false, visible: false,
             can_visible_be_changed: false, can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:reporting_item_discount_amount])

      amount :item_taxable_amount, label: 'Item Taxable Amount', editable: false, visible: true, can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:item_taxable_amount])

      amount :reporting_item_taxable_amount, label: 'Item Taxable Amount(Reporting Currency)', editable: false, visible: false,
             can_visible_be_changed: false, can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:reporting_item_taxable_amount])

      lookup :tax_rate_id, label: "Tax Rate", editable: true, visible: true, choices_scope: Choices[:lookup].('tax_rates'), computed: Forms::Compute::Lookup('items.inventory_line_item_id', '{{record.tax_rate_id}}')
      number :tax_percentage, editable: false, visible: true, computed: Forms::Compute::Lookup('items.tax_rate_id', '{{record.rate}}')

      # tax_amount = taxable_amount x tax / 100
      amount :item_tax_amount, label: 'Item Tax Amount', editable: false, visible: true,
             can_editable_be_changed: false, can_visible_be_changed: false, 
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:item_tax_amount])

      amount :reporting_item_tax_amount, label: 'Item Tax Amount(Reporting Currency)', editable: false, visible: false,
             can_visible_be_changed: false, can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:reporting_item_tax_amount])

      amount :item_net_amount, label: "Net Amount", editable: false, visible: true,
             can_editable_be_changed: false, can_visible_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:item_net_amount])

      amount :reporting_item_net_amount, label: "Net Amount(Reporting Currency)", editable: false, visible: false,
             can_visible_be_changed: false, can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:reporting_item_net_amount])
    end

    large_text :vendor_note, label: "Vendor Note", editable: true, visible: true,
          can_visible_be_changed: false, can_editable_be_changed: false
  end

  # PURCHASE ORDER ITEMS SUMMARY
  section :summary do
    summary :items_summary do
      amount :po_gross_amount, label: 'Gross Amount', editable: false, visible: true,
             can_editable_be_changed: false, can_visible_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:po_gross_amount])

      amount :reporting_po_gross_amount, label: 'Gross Amount(Reporting Currency)', editable: false, visible: false,
             can_visible_be_changed: false,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_po_gross_amount])

      amount :po_discount_amount, label: "Total Discount", visible: true,
             editable: false, can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:po_discount_amount])

      amount :reporting_po_discount_amount, editable: false, visible: false,
             can_visible_be_changed: false, label: "Total Discount ( Reporting Currency )",
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_po_discount_amount])

      amount :po_taxable_amount, label: 'Taxable Amount', editable: false, visible: false,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:po_taxable_amount])

      amount :reporting_po_taxable_amount, label: 'Taxable Amount(Reporting Currency)', editable: false, visible: false,
             can_editable_be_changed: false, can_visible_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_po_taxable_amount])

      amount :po_tax_amount, label: 'Tax Amount', editable: false, visible: true,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:po_tax_amount])

      amount :reporting_po_tax_amount, label: 'Tax Amount(Reporting Currency)', editable: false, visible: false,
             can_visible_be_changed: false, can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_po_tax_amount])

      amount :po_sub_total_amount, label: 'Net Amount', editable: false, visible: true,
             can_visible_be_changed: false, can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:po_sub_total_amount]) # todo - changd name

      amount :reporting_po_sub_total_amount, label: 'Net Amount(Reporting Currency)', editable: false, visible: true,
             can_visible_be_changed: false, can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_po_sub_total_amount]) # todo - changd name

      number :po_roundoff_amount, label: 'Roundoff Amount', visible: true, editable: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:po_roundoff_amount]) # todo - changd name

      amount :reporting_po_roundoff_amount, label: 'Roundoff Amount(Reporting Currency)', editable: false, visible: false,
             can_visible_be_changed: false, can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_po_roundoff_amount]) # todo - changd name

      amount :po_total_amount, label: 'Total Amount', editable: false, visible: false,
             can_editable_be_changed: false, can_visible_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:po_total_amount])

      amount :reporting_po_total_amount, label: 'Total Amount(Reporting Currency)', editable: false, visible: false,
             can_visible_be_changed: false, can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_po_total_amount])

      amount :po_balance_due, label: "Balance Payable", editable: false, visible: true,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:po_balance_due])

      amount :reporting_po_balance_due, label: "Balance Payable(Reporting Currency)", editable: false, visible: true,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_po_balance_due]),
             can_visible_be_changed: false, can_editable_be_changed: false
    end
  end

  # Advance Payment
  # section :document_advance, title: "Document Advance" do
  #   dropdown :advance_amount_required, label: "Required ", editable: true, visible: true, required: true, choices_scope: Choices[:list].({ id: 'true', name: 'Yes' }, { id: 'false', name: 'No' }), default_value: 'false'
      
  #   amount :po_requested_advance_amount, label: "Amount", editable: false, visible: true,
  #          can_editable_be_changed: false, can_visible_be_changed: false,
  #          computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:po_requested_advance_amount])

  #   amount :reporting_po_requested_advance_amount, label: "Reporting Amount", editable: false, visible: true,
  #          can_editable_be_changed: false,
  #          computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_po_requested_advance_amount])

  #   lookup :advance_tds_slab_id, label: 'Tds Rate-(%)', choices_scope: Choices[:lookup].('tds_slabs'), 
  #          visible: true, editable: false

  #   number :po_advance_tds_percentage, internal: true, editable: false, visible: true,
  #          can_editable_be_changed: false, can_visible_be_changed: false,
  #          computed: Forms::Compute::Lookup('advance_tds_slab_id', '{{record.tds}}')

  #   amount :po_advance_tds_amount, label: "Tds Amount", editable: false, visible: true,
  #          can_editable_be_changed: false, can_visible_be_changed: false,
  #          computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:po_advance_tds_amount])
    
  #   amount :reporting_po_advance_tds_amount, label: "Reporting Tds Amount", editable: false, visible: true,
  #          can_editable_be_changed: false, can_visible_be_changed: false,
  #          computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_po_advance_tds_amount])

  #   amount :po_advance_amount, label: "Net Advance Amount", editable: false, visible: true,
  #          can_editable_be_changed: false, can_visible_be_changed: false,
  #          computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:po_advance_amount])

  #   amount :reporting_po_advance_amount, label: "Reporting Net Advance Amount", editable: false, visible: true,
  #          can_editable_be_changed: false, can_visible_be_changed: false,
  #          computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_po_advance_amount])

  #   lookup :advance_amount_status_id, label: 'Status', editable: false, visible: true,
  #          can_editable_be_changed: false, can_visible_be_changed: false
  # end

  # PO advances using old logic
  section :document_advance, title: "Document Advance" do
    switch :advance_amount_required, label: "Required", editable: true, visible: true, required: true, default_value: false

    amount :po_requested_advance_amount, label: "Amount", editable: false, visible: true, required: true,
           can_editable_be_changed: false, can_visible_be_changed: false,
           computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:po_requested_advance_amount])

    amount :reporting_po_requested_advance_amount, label: "Reporting Amount", editable: false, visible: true,
           can_editable_be_changed: false,
           computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_po_requested_advance_amount])

    lookup :advance_tds_slab_id, label: 'Tds Rate-(%)', choices_scope: Choices[:lookup].('tds_slabs'), 
           visible: true, editable: false

    number :po_advance_tds_percentage, internal: true, editable: false, visible: false,
           can_editable_be_changed: false, can_visible_be_changed: false,
           computed: Forms::Compute::Lookup('advance_tds_slab_id', '{{record.tds}}')

    amount :po_advance_tds_amount, label: "Tds Amount", editable: false, visible: false,
           can_editable_be_changed: false, can_visible_be_changed: false,
           computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:po_advance_tds_amount])

    amount :po_advance_amount, label: "Net Advance Amount", editable: false, visible: true,
           can_editable_be_changed: false, can_visible_be_changed: false,
           computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:po_advance_amount])

    amount :reporting_po_advance_amount, label: "Reporting Net Advance Amount", editable: false, visible: true,
           can_editable_be_changed: false, can_visible_be_changed: false,
           computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_po_advance_amount])

    date :advance_scheduled_date, label: "Scheduled Date", editable: true, visible: true
    lookup :advance_amount_status_id, label: 'Status', editable: false, visible: true,
           can_editable_be_changed: false, can_visible_be_changed: false, choices_scope: Choices[:lookup].('advance_amount_statuses'), 
           default_value: AdvanceAmountStatus.id_for(:new)
       
  end


  # PURCHASE ORDER ITEMS
  section :quotations, associate_custom_fields: true do
    table :quotations, populate_if_empty: Quotation do

      number :id, visible: false, editable: false, internal: true, can_visible_be_changed: false, can_editable_be_changed: false
      text :vendor_name, label: 'Vendor Name', editable: true, visible: true, required: true, minimum: 3
      text :vendor_location, label: 'Vendor Location', editable: true, visible: true, required: true, minimum: 3
      date :estimated_delivery_time, label: 'Estd. Delivery Date', editable: true, visible: true, required: true
      number :total_amount, label: 'Total Amount', editable: true, visible: true, required: true
      number :advance_amount, label: 'Advance Amount', editable: true, visible: true
      text :credit_period, label: 'Credit Period', editable: true, visible: true

      large_text :note, editable: true, visible: true, required: true
      dropdown :selected, editable: true, visible: true, choices_scope: Choices[:list].({ id: 1, name: 'true' }, { id: 2, name: 'false' }), default_value: 2

    end
  end

  # ATTACHMENTS
  section :attachments, associate_custom_fields: true do
    attachment :attachments, system_field: false
  end

  # VALIDATIONS
  validation validation_id: "Order Date Cannot be Later than Delivery Date" do
    reference 'delivery_date'
    error_message "Order Date Cannot be Later than Delivery Date"
    rule Rules::Builder['delivery_date'].lt(entity: "created_at")
  end

  validation validation_id: "Items > Item net amount cannot be less than 0" do
    reference 'items.item_net_amount'
    error_message "Item net amount cannot be less than 0"
    rule Rules::Builder['items.net_amount'].lt(value: 0)
  end

  validation validation_id: "Advance amount should be less than payable amount" do
    reference 'po_requested_advance_amount'
    error_message "Advance can not be more than Balance Payable"
    rule Rules::Builder['po_requested_advance_amount'].gt(entity: "po_balance_due")
  end

  # validation validation_id: "Advance Amount Can not be greater than Balance Payable" do
  #   reference 'po_requested_advance_amount'
  #   error_message "Advance Amount Can not be greater than Balance Payable"
  #   rule Rules::Builder['po_requested_advance_amount'].gt(entity: "items_summary.po_balance_due")
  # end

  # CONDITIONS
  condition condition_id: "Policy should not be editable once unless in editable status" do
    reference :entity, :policy_id
    rule Rules::Builder[:purchase_order_status_id].eq_any(*PurchaseOrderStatus.ids_for(:open, :retracted, :rejected).map { |item| { value: item } })
    action :editable, true
    action :required, true
  end

  condition condition_id: "Enable Bank Accounts > Swift / BIC Code for International Vendors" do
    reference :entity, 'vendor_bank_account_swift_code'
    rule Rules::Builder[:vendor_country_id_value].not_eq(value: 'India')
    action :visible, true
    action :required, true
  end

  condition condition_id: "Disable Vendor Location > No Location for International Vendors" do
    reference :entity, 'gstin_location_id'
    rule Rules::Builder[:vendor_country_id_value].not_eq(value: 'India')
    action :visible, false
    action :required, false
  end

  condition condition_id: "Disable Vendor Gstin > No Gstin for International Vendors" do
    reference :entity, 'vendor_gstin'
    rule Rules::Builder[:vendor_country_id_value].not_eq(value: 'India')
    action :visible, false
    action :required, false
  end

  condition condition_id: "Disable Vendor Pan > No Pan for International Vendors" do
    reference :entity, 'vendor_pan'
    rule Rules::Builder[:vendor_country_id_value].not_eq(value: 'India')
    action :visible, false
    action :required, false
  end

  condition condition_id: "Disable Vendor POC name for international vendors" do
    reference :entity, 'vendor_poc_name'
    rule Rules::Builder[:vendor_country_id_value].not_eq(value: 'India')
    action :visible, false
  end

  condition condition_id: "Disable Vendor POC email for international vendors" do
    reference :entity, 'vendor_poc_email'
    rule Rules::Builder[:vendor_country_id_value].not_eq(value: 'India')
    action :visible, false
  end

  condition condition_id: "Disable Vendor POC mobile for international vendors" do
    reference :entity, 'vendor_poc_mobile_number'
    rule Rules::Builder[:vendor_country_id_value].not_eq(value: 'India')
    action :visible, false
  end

  condition condition_id: "Disable Bank Accounts > IFS Code for International Vendors" do
    reference :entity, 'vendor_bank_account_ifsc'
    rule Rules::Builder[:vendor_country_id_value].not_eq(value: 'India')
    action :visible, false
    action :required, false
  end

  condition condition_id: "Disable HSN/SAC for international vendor" do
    reference :entity, 'items.hsn_sac'
    rule Rules::Builder[:vendor_country_id_value].not_eq(value: 'India')
    action :visible, false
  end

  condition condition_id: "Base Currency non editable for Indian vendor" do
    reference :entity, 'base_currency_id'
    rule Rules::Builder[:vendor_country_id_value].not_eq(value: 'India')
    action :editable, true
  end

  condition condition_id: "Disable item department > Item department not for Header Cost Allocation Items" do
    reference :entity, 'items.items_department_id'
    rule Rules::Builder[:cost_allocation_items].eq_any(value: true)
    action :visible, true
    action :required, true
    action :editable, true
  end

  condition condition_id: "Enable item department > Item Cost Center for Header Cost Allocation Items" do
    reference :entity, 'department_id'
    rule Rules::Builder[:cost_allocation_items].eq_any(value: true)
    action :visible, false
    action :required, false
    action :editable, false
  end

  condition condition_id: "Disable item Cost Center > Item Cost Center not for Header Cost Allocation Items" do
    reference :entity, 'items.items_cost_center_id'
    rule Rules::Builder[:cost_allocation_items].eq_any(value: true)
    action :visible, true
    action :required, true
    action :editable, true
  end

  condition condition_id: "Enable item Cost Center > Item Cost Center for Header Cost Allocation Items" do
    reference :entity, 'cost_center_id'
    rule Rules::Builder[:cost_allocation_items].eq_any(value: true)
    action :visible, false
    action :required, false
    action :editable, false
  end

  condition condition_id: "Hide Conversion Rate for Indian currency" do
    reference :entity, 'conversion_rate'
    rule Rules::Builder[:base_currency_id].eq(entity: "reporting_currency_id")
    action :visible, false
  end

  condition condition_id: "Hide Roundoff for different currency" do
    reference :entity, 'items_summary.po_roundoff_amount'
    rule Rules::Builder[:base_currency_id].not_eq(entity: "reporting_currency_id")
    action :visible, false
  end

  condition condition_id: "Hide Net Amount (Reporting Currency)" do
    reference :entity, 'items_summary.reporting_po_sub_total_amount'
    rule Rules::Builder[:base_currency_id].eq(entity: "reporting_currency_id")
    action :visible, false
  end

  condition condition_id: "Hide Reporting Balance Payable for Indian Currency" do
    reference :entity, 'items_summary.reporting_po_balance_due'
    rule Rules::Builder[:base_currency_id].eq(entity: "reporting_currency_id")
    action :visible, false
  end

  condition condition_id: "Hide Reporting Advance Amount for Indian Currency" do
    reference :entity, 'reporting_po_requested_advance_amount'
    rule Rules::Builder[:base_currency_id].eq(entity: "reporting_currency_id")
    action :visible, false
  end

  condition condition_id: "Hide Reporting Advance payable amount for Indian Currency" do
    reference :entity, 'reporting_po_advance_amount'
    rule Rules::Builder[:base_currency_id].eq(entity: "reporting_currency_id")
    action :visible, false
  end

  condition condition_id: "make advance editable and required for document advance true" do
    reference :entity, 'po_requested_advance_amount'
    rule Rules::Builder[:advance_amount_required].eq_any(value: true)
    action :required, true
    action :editable, true
  end

  condition condition_id: "make advance tds editable for document advance true" do
    reference :entity, 'advance_tds_slab_id'
    rule Rules::Builder[:advance_amount_required].eq_any(value: true)
    action :editable, true
  end

  condition condition_id: "make advance scheduled date required for document advance true" do
    reference :entity, 'advance_scheduled_date'
    rule Rules::Builder[:advance_amount_required].eq_any(value: true)
    action :editable, true
    action :required, true
  end

  # condition condition_id: "Make Advance Amount Editable" do
  #   reference :entity, 'po_requested_advance_amount'
  #   rule Rules::Builder[:advance_amount_required].eq(value: 'true')
  #   action :editable, true
  # end

  # condition condition_id: "Make Tds applied Editable" do
  #   reference :entity, 'advance_tds_slab_id'
  #   rule Rules::Builder[:advance_amount_required].eq(value: 'true')
  #   action :editable, true
  # end

  condition condition_id: "Disable Shipping address gstin for International" do
    reference :entity, 'shipping_address_gstin'
    rule Rules::Builder[:vendor_country_id_value].not_eq(value: 'India')
    action :visible, false
    action :required, false
  end

  condition condition_id: "Disable Billing address gstin for International" do
    reference :entity, 'billing_address_gstin'
    rule Rules::Builder[:vendor_country_id_value].not_eq(value: 'India')
    action :visible, false
    action :required, false
  end

  condition condition_id: "Enable PR Number for POs from PR" do
    reference :entity, 'items.pr_number'
    rule Rules::Builder['row.purchase_request_item_id'].present.and(Rules::Builder['row.purchase_request_item_id'].not_eq(value: ''))
    action :visible, true
  end
end