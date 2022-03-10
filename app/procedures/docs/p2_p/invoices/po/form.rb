class Docs::P2P::Invoices::Po::Form < Forms::API
  model Invoice

  meta ->(record) {
    {
      created_by: {
        id: record.created_by&.id,
        name: record.created_by&.name,
        email: record.created_by&.email
      },
      company_country_id: record.company.country_id.to_s
    }
  }

  # LIQUID FORMULAE
  LIQUID_FORMULAE = {
    items: {
      item_gross_amount: '{{ row.rate | times: row.quantity | default: 0 | round: 2  }}',
      item_billable_amount: "{% if row.product_type_id == '2' %}{{ row.item_billable_amount| default: 0 | round: 2 }}{% else %}{{ 0 }}{% endif %}", # TODO: - I2P will be different for PO invoice

      # item_discount_amount: "{% if form.discount_type_id == 1 %}{{ row.item_gross_amount | times: row.discount | divided_by: 100.00 | default: 0 | round: 2 }}{% else %}{{ row.discount | default: 0 }}{% endif %}",
      item_discount_amount: "{% if row.product_type_id == '2' %}{{ row.item_discount_amount | default: 0 }}{% else %}{% if form.discount_type_id == 1 %}{{ row.item_gross_amount | times: row.discount | divided_by: 100.00 | default: 0 | round: 2 }}{% else %}{{ row.discount | default: 0 }}{% endif %}{% endif %}",

      # item_taxable_amount: "{{ row.item_gross_amount | minus: row.item_discount_amount | default: 0 | round: 2  }}",
      item_taxable_amount: "{% if row.product_type_id == '1' %}{{ row.item_gross_amount | minus: row.item_discount_amount | default: 0 | round: 2  }}{% else %}{{ row.item_billable_amount }}{% endif %}",
      item_tax_amount: '{{ row.item_taxable_amount | times: row.tax_percentage | divided_by: 100.00 | default: 0 | round: 2  }}',
      item_tds_amount: "
      {% if row.tds_applicable == 'true' %}
        {{ row.item_taxable_amount | times: form.tds_percentage | divided_by: 100.00 | default: 0 | round: 2  }}
      {% else %}
        {{ 0 }}
      {% endif %}
      ",
      item_net_amount: '{% if form.rcm_enabled == true %}{{ row.item_taxable_amount | default: 0 | round: 2 }}{% else %}{{ row.item_taxable_amount | plus: row.item_tax_amount | default: 0 | round: 2 }}{% endif %}',

      # CONVERTED VALUES
      reporting_item_gross_amount: '{{ row.item_gross_amount | times: form.conversion_rate | default: 0 | round: 2}}',
      reporting_item_billable_amount: ' {{ row.item_billable_amount | times: form.conversion_rate | default: 0 | round: 2  }}',
      reporting_item_discount_amount: ' {{ row.item_discount_amount | times: form.conversion_rate | default: 0 | round: 2}}',
      reporting_item_taxable_amount: '{{ row.item_taxable_amount | times: form.conversion_rate | default: 0 | round: 2}}',
      reporting_item_tax_amount: '{{ row.item_tax_amount | times: form.conversion_rate | default: 0 | round: 2  }}',
      reporting_item_tds_amount: '{{ row.item_tds_amount | times: form.conversion_rate | default: 0 | round: 2  }}',
      reporting_item_net_amount: '{{ row.item_net_amount | times: form.conversion_rate | default: 0 | round: 2  }}'
    },

    # INVOICE SUMMARY
    summary: {
      invoice_gross_amount: "{% assign gross_amount = 0 %}{% for item in form.items %}{% if item._destroy == true %}{% continue %}{% elsif item.product_type_id == '1' %}{% assign gross_amount = gross_amount | plus: item.item_gross_amount %}{% else %}{% assign gross_amount = gross_amount | plus: item.item_billable_amount %}{% endif %}{% endfor %}{{ gross_amount | default: 0 | round: 2 }}",

      invoice_discount_amount: '{% assign discount_amount = 0 %}{% for item in form.items %}{% if item._destroy == true %}{% continue %}{% else %}{% assign discount_amount = discount_amount | plus: item.item_discount_amount %}{% endif %}{% endfor %}{{ discount_amount | default: 0 | round: 2 }}',
      invoice_taxable_amount: '{{ form.invoice_gross_amount | minus: form.invoice_discount_amount | default: 0 | round: 2}}',
      invoice_tax_amount: '{% assign tax_amount = 0 %}{% for item in form.items %}{% if item._destroy == true %}{% continue %}{% else %}{% assign tax_amount = tax_amount | plus: item.item_tax_amount %}{% endif %}{% endfor %}{{ tax_amount  | default: 0 | round: 2}}',
      invoice_freight_amount: '{{ form.invoice_freight_amount | default: 0 | round: 2}}',
      # NET AMOUNT
      invoice_sub_total_amount: '{% assign inv_sub_total_amount = form.invoice_gross_amount | minus: form.invoice_discount_amount | plus: form.invoice_tax_amount | plus: form.invoice_freight_amount | round: 2 %}{% if form.rcm_enabled == true %}{{ inv_sub_total_amount | minus: form.invoice_tax_amount | default: 0 | round: 2}}{% else %}{{ inv_sub_total_amount | default: 0 | round: 2 }}{% endif %}',
      invoice_paid_outside_amount: '{{ form.invoice_paid_outside_amount | default: 0 | round: 2}}',
      # invoice_tds_amount: "{% assign tds_amount = 0 %}{% for item in form.items %}{% if item._destroy == true %}{% continue %}{% else %}{% assign tds_amount = tds_amount | plus: item.item_tds_amount %}{% endif %}{% endfor %}{{ tds_amount  | default: 0 | ceil}}",
      display_tds_amount: "
      {% assign tds_amount = 0 %}
      {% for item in form.items %}
        {% if item._destroy == true or item.tds_applicable == 'false'%}
          {% continue %}
        {% else %}
          {% assign tds_amount = tds_amount | plus: item.item_tds_amount %}
        {% endif %}
      {% endfor %}
      {{ tds_amount  | default: 0 | ceil }}
      ",

      #### net payable amount
      # invoice_roundoff_amount: "{% assign net_total_amount = form.invoice_sub_total_amount | minus: form.invoice_paid_outside_amount | minus: form.invoice_tds_amount %}{% assign round_amount = net_total_amount | round %}{% assign amount = round_amount | minus: net_total_amount %}{% if form.base_currency_id != form.reporting_currency_id %}{% assign amount = 0 %}{% endif %}{{ amount | default: 0 | round: 2 }}",
      invoice_roundoff_amount: "
      {% assign net_total_amount = form.invoice_sub_total_amount | minus: form.invoice_paid_outside_amount | minus: form.invoice_tds_amount %}
      {% assign round_amount = net_total_amount | round %}
      {% assign amount = round_amount | minus: net_total_amount %}
      {% if form.base_currency_id == '#{Currency.id_for('INR')}' and form.reporting_currency_id == '#{Currency.id_for('INR')}' %}
        {{ amount | default: 0 | round: 2 }}
      {% else %}
        {{ 0 }}
      {% endif %}
      ",

      invoice_net_total_amount: "{% if form.base_currency_id == '#{Currency.id_for('INR')}' and form.reporting_currency_id == '#{Currency.id_for('INR')}' %}{{ form.invoice_total_amount | default: 0 | round }}{% else %}{{ form.invoice_total_amount | default: 0 | round: 2 }}{% endif %}",
      invoice_total_amount: '{{ form.invoice_sub_total_amount | plus: form.invoice_roundoff_amount | minus: form.display_tds_amount | minus: form.invoice_paid_outside_amount | default: 0 | round: 2}}',

      #### net payable amount has roundoff value added
      # invoice_net_total_amount: "{% if form.base_currency_id != form.reporting_currency_id %}{{ form.invoice_total_amount | default: 0 | round: 2 }}{% else %}{{ form.invoice_total_amount | default: 0 | round }}{% endif %}",
      # invoice_advance_paid_amount: "{% form.advance_amount_required == false %}{{0}}{% else %}{{ form.adjusted_po_advance_payable_amount | default: 0 | round: 2}}{% endif %}",
      invoice_advance_paid_amount: '{% if form.advance_amount_required == true %}{{ form.adjusted_po_advance_payable_amount | default: 0 | round: 2}}{% endif %}',
      invoice_balance_due: '{{ form.invoice_total_amount | minus: form.invoice_advance_paid_amount | default: 0 | round: 2 | at_least: 0 }}',
      adjusted_po_advance_payable_amount: '
      {% assign payable_balance = form.invoice_sub_total_amount | plus: form.invoice_roundoff_amount | minus: form.display_tds_amount | minus: form.invoice_paid_outside_amount | default: 0 | round: 2 %}
      {% assign adjustable_advance = form.po_advance | minus: form.po_prev_adjusted_advance %}
      {% if payable_balance <= adjustable_advance and form.advance_amount_required == true %}
        {{ payable_balance | round: 2}}
      {% elsif payable_balance > adjustable_advance and form.advance_amount_required == true %}
        {{ adjustable_advance| round: 2}}
      {% endif %}
      ',
      adjusted_advance_tds: '
      {% assign invoice_tds = form.display_tds_amount %}
      {% assign adjustable_tds = form.po_advance_tds | minus: form.prev_adjusted_advance_tds %}
      {% if invoice_tds <= adjustable_tds and form.advance_amount_required == true %}
        {{ invoice_tds | round: 2}}
      {% elsif invoice_tds > adjustable_tds and form.advance_amount_required == true %}
        {{ adjustable_tds | round: 2}}
      {% endif %}
      ',
      remaining_adjustable_advance: '
      {% assign remaining_advance = form.po_advance | minus: form.po_prev_adjusted_advance %}
      {% if form.advance_amount_required == true %}
        {{ remaining_advance | minus: form.adjusted_po_advance_payable_amount | round: 2}}
      {% else %}
        {{ remaining_advance | round: 2}}
      {% endif %}
      ',
      remaining_adjustable_tds: '
      {% assign remaining_tds = form.po_advance_tds | minus: form.prev_adjusted_advance_tds %}
      {% if form.advance_amount_required == true %}
        {{ remaining_tds | minus: form.adjusted_advance_tds | round: 2}}
      {% else %}
        {{ remaining_tds | round: 2}}
      {% endif %}
      ',

      # CONVERTED VALUES
      reporting_invoice_gross_amount: '{{ form.invoice_gross_amount | times: form.conversion_rate | default: 0 | round: 2}}',
      reporting_invoice_discount_amount: '{{ form.invoice_discount_amount | times: form.conversion_rate | default: 0 | round: 2}}',
      reporting_invoice_taxable_amount: '{{ form.invoice_taxable_amount | times: form.conversion_rate | default: 0 | round: 2}}',
      reporting_invoice_tax_amount: '{{ form.invoice_tax_amount | times: form.conversion_rate | default: 0 | round: 2}}',
      reporting_invoice_freight_amount: '{{ form.invoice_freight_amount | times: form.conversion_rate | default: 0 | round: 2}}',
      reporting_invoice_sub_total_amount: '{{ form.invoice_sub_total_amount | times: form.conversion_rate | default: 0 | round: 2}}',
      reporting_invoice_paid_outside_amount: '{{ form.invoice_paid_outside_amount | times: form.conversion_rate | default: 0 | round: 2}}',
      reporting_invoice_roundoff_amount: "{% assign amount = form.reporting_invoice_sub_total_amount | round %}{% assign amount = amount | minus: form.reporting_invoice_sub_total_amount %}{% if form.base_currency_id == '#{Currency.id_for('INR')}' and form.reporting_currency_id == '#{Currency.id_for('INR')}' %}{{ amount | default: 0 | round: 2}}{% else %}{{ 0 }}{% endif %}",
      reporting_invoice_tds_amount: '{{ form.display_tds_amount | times: form.conversion_rate | default: 0 | round: 2}}',
      reporting_invoice_total_amount: '{{ form.invoice_total_amount | times: form.conversion_rate | default: 0 | round: 2}}',

      reporting_invoice_net_total_amount: '{{ form.invoice_net_total_amount | times: form.conversion_rate | default: 0 | round: 2}}',
      reporting_invoice_advance_paid_amount: '{{ form.invoice_advance_paid_amount | times: form.conversion_rate | default: 0 | round: 2}}',
      reporting_invoice_balance_due: '{{ form.invoice_balance_due | times: form.conversion_rate | default: 0 | round: 2}}',
      reporting_po_advance: '{{ form.po_advance | times: form.conversion_rate | default: 0 | round: 2}}',
      reporting_po_prev_adjusted_advance: '{{ form.po_prev_adjusted_advance | times: form.conversion_rate | default: 0 | round: 2}}',
      reporting_adjusted_po_advance_payable_amount: '{{ form.adjusted_po_advance_payable_amount | times: form.conversion_rate | default: 0 | round: 2}}'
    }
  }

  # INVOICE STATUS
  section :status do
    lookup :invoice_status_id,
           choices_scope: Choices[:lookup].('inward_invoice_statuses'),
           required: false, editable: false,
           default_value: InwardInvoiceStatus.id_for(:open),
           can_editable_be_changed: false
  end

  # INVOICE DETAILS
  section :invoice_details, title: 'Invoice Details', associate_custom_fields: true do
    auto_number :invoice_id, label: 'Sequence Number', editable: false, visible: true,
                             sequence: { prefix: 'INV', start_at: '00001' }

    text :invoice_number, label: 'Invoice Number', required: true, unique: true

    text :po_number, label: 'Po Number', required: true, editable: false

    date :date,
         label: 'Invoice Date',
         computed: Forms::Compute::Form('{{ form.date | default: "now" | date: "%Y-%m-%d" }}'),
         required: true, editable: true, visible: true,
         restriction: 'not_in_the_future'

    lookup :payment_term_id,
           choices_scope: Choices[:lookup].('payment_terms'),
           label: 'Payment Term', visible: true, required: true, editable: true

    number :payment_term_days,
           label: 'Payment Term Days', visible: false,
           computed: Forms::Compute::Lookup('payment_term_id', '{{record.days_after | default: 0 }}')

    date :due_date,
         computed: Forms::Compute::Form('{% assign assigne_days = form.payment_term_days | times: 86400 %}{% assign calculated_date = form.date | date: "%s" | plus: assigne_days %}{{ calculated_date  | date: "%Y-%m-%d" }}'),
         visible: true, required: true, editable: true

    switch :cost_allocation_items, label: 'Cost Allocation ( Line Items)', required: true, visible: true, editable: true, default_value: false

    date :transaction_service_period_from, label: 'Transaction Service Period (From Date)', editable: true, visible: true, computed: Forms::Compute::Form('{{ form.transaction_service_period_from | default: "now" | date: "%Y-%m-%d" }}')
    date :transaction_service_period_to, label: 'Transaction Service Period (To Date)', editable: true, visible: true, computed: Forms::Compute::Form('{{ form.transaction_service_period_to | default: "now" | date: "%Y-%m-%d" }}')

    large_text :narration, label: 'Narration', visible: true
  end

  # ACCOUNTING DETAILS
  section :accounting_details, title: 'Accounting Details', associate_custom_fields: true do
    lookup :policy_id, choices_scope: Choices[:lookup].('policies', permissions: [:po_invoice_initiator]), required: true, editable: false
    lookup :department_id, label: 'Department', editable: true, visible: true, required: true, choices_scope: Choices[:lookup].('departments', assignments: { form: true }) # , editable: false, visible: false
    lookup :cost_center_id, label: 'Cost Center', editable: true, visible: true, required: true, choices_scope: Choices[:lookup].('cost_centers')
    dropdown :discount_type_id, label: 'Discount Type', editable: false, can_editable_be_changed: false, visible: false, required: true, choices_scope: Choices[:list].({ id: 1, name: 'Percentage' }, { id: 2, name: 'Amount' }), default_value: 1
    text :discount_type_text, label: 'Discount Type', editable: false, visible: true, can_editable_be_changed: false

    dropdown :tax_type_id, label: 'Tax Type', editable: true, visible: true, choices_scope: Choices[:list].(*TaxType.all.map { |v| { id: v.id, name: v.name } })

    date :conversion_date, label: 'Conversion Date', editable: false, visible: true, computed: Forms::Compute::Form('{{form.date}}'), triggers: { on_change: { lookup_details: [:base_currency_id] }, on_compute: { lookup_details: [:base_currency_id] } }

    lookup :reporting_currency_id, label: 'Reporting Currency', choices_scope: Choices[:lookup].('currencies'), visible: true, editable: false, can_editable_be_changed: false
    lookup :base_currency_id, label: 'Base Currency', choices_scope: Choices[:lookup].('currencies'), visible: true, editable: false

    switch :retrieve_conversion_rate, label: 'Auto Populate Conversion Rate', default_value: true, visible: false
    number :conversion_rate, editable: true, format: 'decimal', max_decimal_places: 5, default_value: 1, computed: Forms::Compute::Lookup('base_currency_id', '{{ record.currency_conversion_rate }}', assignments: { conversion_date: '{{form.conversion_date}}', to_currency: '{{form.reporting_currency_id}}' }), visible: true
  end

  # VENDOR DETAILS
  section :vendor_details, title: 'Vendor Details', associate_custom_fields: true do
    lookup :vendor_id, label: 'Vendor', choices_scope: Choices[:lookup].('vendors'), required: true, editable: false,
                       can_editable_be_changed: false, can_be_disabled: false, can_required_be_changed: false, can_visible_be_changed: false

    lookup :vendor_trade_name, label: 'Vendor Trade Name', editable: false, visible: true, computed: Forms::Compute::Lookup('vendor_id', '{{record.trade_name}}', assignments: { created_by_id: '{{meta.created_by_id}}' })
    lookup :vendor_country_id, editable: false, visible: true, choices_scope: Choices[:lookup].('countries')

    text :vendor_sequence_id, 'Vendor ID', editable: false, computed: Forms::Compute::Lookup('vendor_id', '{{record.vendor_id}}')

    lookup :gstin_location_id, label: 'Vendor Location', choices_scope: Choices[:lookup].('vendor_locations'), # TODO: - condition to hide for international
                               filters: Rules::Builder[:vendor_id].eq(entity: :vendor_id)
    text :vendor_gstin, 'Vendor GSTIN', editable: false, computed: Forms::Compute::Lookup('gstin_location_id', '{{record.gstin}}') # TODO: - condition

    text :vendor_pan, 'Vendor PAN', editable: false # TODO: - add condition

    lookup :receiving_account_id, label: 'Vendor Account', choices_scope: Choices[:lookup].('vendor_bank_accounts'),
                                  filters: Rules::Builder[:account_owner_id].eq(entity: 'vendor_id').and(Rules::Builder[:account_owner_type].eq(value: 'YesBankVendor')),
                                  editable: false, visible: true, required: true

    text :receiving_account_type, visible: false, internal: true, editable: false, computed: Forms::Compute::Form('BankAccount')
    switch :rcm_enabled, label: 'RCM Enabled', editable: true, visible: true, computed: Forms::Compute::Lookup('vendor_id', '{{record.rcm_enabled}}'), default_value: true

    text :vendor_bank_account_number, editable: false, can_editable_be_changed: false, computed: Forms::Compute::Lookup('receiving_account_id', '{{record.account_number}}')
    text :vendor_bank_account_ifsc, editable: false, required: true, can_editable_be_changed: false, computed: Forms::Compute::Lookup('receiving_account_id', '{{record.ifsc}}')
    text :vendor_bank_account_swift_code, editable: false, visible: false, required: false, can_editable_be_changed: false, computed: Forms::Compute::Lookup('receiving_account_id', '{{record.swift_code}}')
  end

  # BILLING ADDRESS
  section :billing_address do
    lookup :location_id, label: 'Billing Address', choices_scope: Choices[:lookup].('locations', assignments: { form: true }),
                         filters: Rules::Builder['billable_location'].true, required: true
    text :billing_address_name, label: 'Name', editable: false, computed: Forms::Compute::Lookup('location_id', '{{record.name}}')
    text :billing_address_gstin, label: 'Gstin', editable: false, computed: Forms::Compute::Lookup('location_id', '{{record.gstin}}')
    large_text :billing_address, computed: Forms::Compute::Lookup('location_id', '{{record.address}}')
  end

  # SHIPPING ADDRESS
  section :shipping_address do
    lookup :delivery_location_id, label: 'Shipping Address', choices_scope: Choices[:lookup].('locations', assignments: { form: true }),
                                  filters: Rules::Builder['shippable_location'].true, required: true
    text :shipping_address_name, label: 'Name', editable: false, computed: Forms::Compute::Lookup('delivery_location_id', '{{record.name}}')
    text :shipping_address_gstin, label: 'Gstin', editable: false, computed: Forms::Compute::Lookup('delivery_location_id', '{{record.gstin}}')
    large_text :shipping_address, computed: Forms::Compute::Lookup('delivery_location_id', '{{record.address}}')
  end

  # INVOICE ITEMS
  section :items, associate_custom_fields: true do
    table :items, min_items: 1, populate_if_empty: InvoiceLineItem do
      number :id, visible: false, editable: false, internal: true, can_visible_be_changed: false, can_editable_be_changed: false

      lookup :inventory_line_item_id, label: 'Item',
                                      can_visible_be_changed: false,
                                      can_editable_be_changed: false,
                                      choices_scope: Choices[:lookup].('items'),
                                      required: true, editable: true, visible: true

      text :description, editable: false,
                         can_editable_be_changed: false,
                         can_visible_be_changed: false, visible: false,
                         computed: Forms::Compute::Lookup('items.inventory_line_item_id', '{{record.description}}')

      text :comment, label: 'Narration'
      text :item_number, label: 'Item Code', editable: false,
                         computed: Forms::Compute::Lookup('items.inventory_line_item_id', '{{record.item_number}}')

      lookup :product_type_id, label: 'Product Type', choices_scope: Choices[:enum].(ProductType), computed: Forms::Compute::Lookup('items.inventory_line_item_id', '{{record.product_type_id}}'), editable: false, required: true, visible: true

      lookup :items_department_id, label: 'Department', editable: false, visible: false, required: false, choices_scope: Choices[:lookup].('departments', assignments: { form: true })
      lookup :items_cost_center_id, label: 'Cost Center', editable: false, visible: false, required: false, choices_scope: Choices[:lookup].('cost_centers')

      lookup :category_id, label: 'Category', required: true, visible: true, editable: true, choices_scope: Choices[:lookup].('categories', scope: :inward_invoice_line_items_only), computed: Forms::Compute::Lookup('items.inventory_line_item_id', '{{record.category_id}}'), triggers: { on_compute: { lookup_details: [:category_id] } }

      text :gl_code, label: 'GL Code', editable: false, visible: false,
                     computed: Forms::Compute::Lookup('items.category_id', '{{record.gl_code_or_item_number}}', assignments: { item_number: '{{row.item_number}}' })

      text :hsn_sac, label: 'HSN/SAC', editable: true, visible: true,
                     computed: Forms::Compute::Lookup('items.inventory_line_item_id', '{{record.hsn_sac}}')

      lookup :tds_applicable, visible: true, editable: false,
                              can_editable_be_changed: false,
                              can_visible_be_changed: false, choices_scope: Choices[:list].({ id: true, name: 'true' }, { id: false, name: 'false' }),
                              computed: Forms::Compute::Lookup('items.inventory_line_item_id', '{{ record.tds_applicable }}')

      number :unbilled_quantity, label: 'Unbiled Quantity', editable: false, visible: false, required: false, min_value: 1 # TODO: - condition
      number :quantity, label: 'Quantity', editable: true, visible: true, required: true, default_value: 1 # TODO: - condition

      dropdown :unit_of_measurement, label: 'Unit of Measurement',
                                     choices_scope: Choices[:list].(*Unit.all.map { |v| { id: v.value, name: v.name } }),
                                     required: true, editable: true, visible: true,
                                     computed: Forms::Compute::Lookup('items.inventory_line_item_id', '{{record.unit_of_measurement}}')

      amount :item_rate, label: 'Item Rate (Reporting Currency)',
                         computed: Forms::Compute::Form('{{ row.rate | times: form.conversion_rate | round: 2 }}'),
                         visible: true, editable: false

      amount :rate, label: 'Rate (Base Currency)',
                    can_editable_be_changed: false, can_visible_be_changed: false,
                    required: true, visible: true, editable: false
      # computed: Forms::Compute::Lookup('items.inventory_line_item_id', '{{ record.rate_in_base_currency | default: 0 | round: 2 }}', assignments: {conversion_date: "{{form.conversion_date}}", base_currency_id: "{{form.base_currency_id}}", reporting_currency_id: "{{form.reporting_currency_id}}", conversion_rate: "{{form.conversion_rate}}"})

      # gross_amount = rate x quantity
      amount :item_gross_amount, label: 'Item Gross Amount', editable: false, visible: false,
                                 can_visible_be_changed: false, can_editable_be_changed: false,
                                 computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:item_gross_amount])

      amount :reporting_item_gross_amount, label: 'Item Gross Amount(Reporting Currency)', editable: false, visible: false,
                                           can_visible_be_changed: false,
                                           can_editable_be_changed: false,
                                           computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:reporting_item_gross_amount])

      amount :item_billable_amount, label: 'Billable Amount', editable: false, visible: true,
                                    can_editable_be_changed: false, can_visible_be_changed: false,
                                    computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:item_billable_amount])

      amount :reporting_item_billable_amount, label: 'Billable Amount(Reporting Currency)', editable: false, visible: false,
                                              can_visible_be_changed: false, can_editable_be_changed: false,
                                              computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:reporting_item_billable_amount])

      number :discount, visible: true, editable: false, default_value: 0

      amount :item_discount_amount, label: 'Item Discount Amount', editable: false, visible: false,
                                    can_editable_be_changed: false,
                                    computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:item_discount_amount])

      amount :reporting_item_discount_amount, label: 'Item Discount Amount(Reporting Currency)', editable: false, visible: false,
                                              can_visible_be_changed: false, can_editable_be_changed: false,
                                              computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:reporting_item_discount_amount])

      amount :item_taxable_amount, label: 'Item Taxable Amount', editable: false, visible: false,
                                   can_editable_be_changed: false,
                                   computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:item_taxable_amount])

      amount :reporting_item_taxable_amount, label: 'Item Taxable Amount(Reporting Currency)', editable: false, visible: false,
                                             can_visible_be_changed: false, can_editable_be_changed: false,
                                             computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:reporting_item_taxable_amount])

      lookup :tax_rate_id, label: 'Tax Rate', editable: true, visible: true, choices_scope: Choices[:lookup].('tax_rates'), computed: Forms::Compute::Lookup('items.inventory_line_item_id', '{{record.tax_rate_id}}')
      number :tax_percentage, editable: false, visible: true, computed: Forms::Compute::Lookup('items.tax_rate_id', '{{record.rate}}')

      amount :item_tax_amount, label: 'Item Tax Amount', editable: false, visible: true,
                               can_editable_be_changed: false, can_visible_be_changed: false,
                               computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:item_tax_amount])

      amount :reporting_item_tax_amount, label: 'Item Tax Amount(Reporting Currency)', editable: false, visible: false,
                                         can_visible_be_changed: false, can_editable_be_changed: false,
                                         computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:reporting_item_tax_amount])

      amount :item_tds_amount, label: 'Tds Amount', editable: false, visible: false,
                               can_editable_be_changed: false, can_visible_be_changed: false,
                               computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:item_tds_amount])

      amount :reporting_item_tds_amount, label: 'Tds Amount(Reporting Currency)', editable: false, visible: false,
                                         can_visible_be_changed: false, can_editable_be_changed: false,
                                         computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:reporting_item_tds_amount])

      amount :item_net_amount, label: 'Net Amount', editable: false, visible: true,
                               can_editable_be_changed: false, can_visible_be_changed: false,
                               computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:item_net_amount])

      amount :reporting_item_net_amount, label: 'Net Amount(Reporting Currency)', editable: false, visible: false,
                                         can_visible_be_changed: false, can_editable_be_changed: false,
                                         computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:reporting_item_net_amount])

      meta ->(record) { # TODO: ID is only for testing. Update this with required meta data.
        {
          id: record.id
        }
      }
    end
  end

  # section :document_advance, title: "Document Advance" do
  #   dropdown :advance_amount_required, label: "Adjust Amount ?", editable: true, visible: true, required: true, choices_scope: Choices[:list].({ id: 'true', name: 'Yes' }, { id: 'false', name: 'No' }), default_value: 'false'
  #   amount :po_advance, label: "PO Advance", editable: false, visible: true, required: false

  #   amount :po_prev_adjusted_advance, label: "Po Prev Adjusted Advance", editable: false, visible: true, required: false
  #   amount :po_prev_adjusted_advance_tds, label: "Po Prev Adjusted Advance TDS", editable: false, visible: true, required: false

  #   amount :po_remaining_adjusted_advance, label: "Po Remaining Adjusted Advance", editable: false, visible: true, required: false
  #   amount :po_remaining_adjusted_advance_tds, label: "Po Remaining Adjusted Advance TDS", editable: false, visible: true, required: false
  # end

  section :document_advance, title: 'Document Advance' do
    switch :advance_amount_required, label: 'Adjust Amount', editable: false, visible: true, default_value: false

    amount :po_advance, label: 'PO Advance payable amount', editable: false, visible: false, required: false
    amount :po_advance_tds, editable: false, visible: false, required: false

    amount :net_po_advance, label: 'PO Advance', editable: false, visible: true, required: true

    # amount :reporting_po_advance, label: 'PO Advance (reporting currency)', editable: false, visible: true, required: false,
    #                               computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_po_advance])

    amount :po_prev_adjusted_advance, label: 'Previous Adjusted Advance', editable: false, visible: true, required: false
    amount :prev_adjusted_advance_tds, label: 'Previous Adjusted AdvanceTDS', editable: false, visible: true, required: false

    # amount :reporting_po_prev_adjusted_advance, label: 'Previous Adjusted Advance (reporting currency)', editable: false, visible: true, required: false,
    #                                             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_po_prev_adjusted_advance])

    amount :adjusted_po_advance_payable_amount, label: 'Current Adjustment', editable: true, visible: true, required: false, computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:adjusted_po_advance_payable_amount])

    # amount :reporting_adjusted_po_advance_payable_amount, label: 'Current Adjustment (reporting currency)', editable: false, visible: true, required: false,
    #                                                       computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_adjusted_po_advance_payable_amount])

    amount :adjusted_advance_tds, label: 'Current TDS Adjustment', editable: false, visible: true, computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:adjusted_advance_tds])
    amount :remaining_adjustable_tds, label: 'Remaining Adjustable TDS', editable: false, visible: true, computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:remaining_adjustable_tds])
    amount :remaining_adjustable_advance, label: 'Remaining Adjustable Advance', editable: false, visible: true, computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:remaining_adjustable_advance])

    switch :advance_paid, editable: false, visible: false
  end

  # INVOICE ITEMS SUMMARY
  section :summary do
    summary :items_summary do
      amount :invoice_gross_amount, label: 'Gross Amount', editable: false, visible: true,
                                    can_editable_be_changed: false, can_visible_be_changed: false,
                                    computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:invoice_gross_amount])

      amount :reporting_invoice_gross_amount, label: 'Gross Amount(Reporting Currency)', editable: false, visible: false,
                                              can_visible_be_changed: false,
                                              can_editable_be_changed: false,
                                              computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_invoice_gross_amount])

      amount :invoice_discount_amount, label: 'Total Discount', visible: true,
                                       editable: false, can_editable_be_changed: false,
                                       computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:invoice_discount_amount])

      amount :reporting_invoice_discount_amount, editable: false, visible: false,
                                                 can_visible_be_changed: false, label: 'Total Discount ( Reporting Currency )',
                                                 can_editable_be_changed: false,
                                                 computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_invoice_discount_amount])

      amount :invoice_taxable_amount, label: 'Taxable Amount', editable: false, visible: false,
                                      can_editable_be_changed: false,
                                      computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:invoice_taxable_amount])

      amount :reporting_invoice_taxable_amount, label: 'Taxable Amount(Reporting Currency)', editable: false, visible: false,
                                                can_editable_be_changed: false, can_visible_be_changed: false,
                                                computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_invoice_taxable_amount])

      amount :invoice_tax_amount, label: 'Tax Amount', editable: false, visible: true,
                                  can_editable_be_changed: false,
                                  computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:invoice_tax_amount])

      amount :reporting_invoice_tax_amount, label: 'Tax Amount(Reporting Currency)', editable: false, visible: false,
                                            can_visible_be_changed: false, can_editable_be_changed: false,
                                            computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_invoice_tax_amount])

      amount :invoice_freight_amount, label: 'Freight',
                                      default_value: 0, visible: true, editable: true,
                                      computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:invoice_freight_amount])

      amount :reporting_invoice_freight_amount, label: 'Freight(Reporting Currency)', editable: false, visible: false,
                                                can_visible_be_changed: false, can_editable_be_changed: false,
                                                computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_invoice_freight_amount])

      amount :invoice_sub_total_amount, label: 'Net Amount', editable: false, visible: true,
                                        can_visible_be_changed: false, can_editable_be_changed: false,
                                        computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:invoice_sub_total_amount]) # TODO: - changd name

      amount :reporting_invoice_sub_total_amount, label: 'Net Amount(Reporting Currency)', editable: false, visible: true,
                                                  can_visible_be_changed: false, can_editable_be_changed: false,
                                                  computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_invoice_sub_total_amount]) # TODO: - changd name

      lookup :tds_slab_id, choices_scope: Choices[:lookup].('tds_slabs'), visible: true, editable: true # TODO: - condition when reporting currency is in INR

      number :tds_percentage, internal: true, editable: false, visible: true, # TODO: - condition when reporting currency is in INR
                              can_editable_be_changed: false,
                              computed: Forms::Compute::Lookup('items_summary.tds_slab_id', '{{record.tds}}')

      amount :invoice_tds_amount, label: 'Tds Amount', editable: false, visible: false, # TODO: - condition when reporting currency is in INR
                                  can_editable_be_changed: false
      # computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:invoice_tds_amount])

      amount :display_tds_amount, label: 'Tds Amount', editable: false, visible: true, # TODO: - condition when reporting currency is in INR
                                  can_editable_be_changed: false,
                                  computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:display_tds_amount])

      amount :reporting_invoice_tds_amount, label: 'Tds Amount(Reporting Currency)',
                                            can_visible_be_changed: false, can_editable_be_changed: false, editable: false, visible: false,
                                            computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_invoice_tds_amount])

      amount :invoice_paid_outside_amount, label: 'Total Partial-Payment', default_value: 0, visible: true, editable: true

      amount :reporting_invoice_paid_outside_amount, label: 'Total Partial-Payment(Reporting Currency)', editable: false, visible: false,
                                                     can_visible_be_changed: false,
                                                     can_editable_be_changed: false,
                                                     computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_invoice_paid_outside_amount])

      number :invoice_roundoff_amount, label: 'Roundoff Amount', visible: false, editable: false,
                                       computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:invoice_roundoff_amount]) # TODO: - changd name

      amount :reporting_invoice_roundoff_amount, label: 'Roundoff Amount(Reporting Currency)', editable: false, visible: false,
                                                 can_visible_be_changed: false,
                                                 can_editable_be_changed: false,
                                                 computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_invoice_roundoff_amount]) # TODO: - changd name

      amount :invoice_total_amount, label: 'Total Amount', editable: false, visible: false,
                                    can_editable_be_changed: false,
                                    can_visible_be_changed: false,
                                    computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:invoice_total_amount])

      amount :reporting_invoice_total_amount, label: 'Total Amount(Reporting Currency)', editable: false, visible: false,
                                              can_visible_be_changed: false,
                                              can_editable_be_changed: false,
                                              computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_invoice_total_amount])

      amount :invoice_net_total_amount, label: 'Net Payable', editable: false, visible: false,
                                        can_editable_be_changed: false,
                                        computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:invoice_net_total_amount])

      amount :reporting_invoice_net_total_amount, label: 'Net Payable (Reporting Currency)', editable: false, visible: false,
                                                  can_editable_be_changed: false,
                                                  computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_invoice_net_total_amount])

      amount :invoice_advance_paid_amount, label: 'Advance Paid',
                                           default_value: 0, editable: false, visible: true,
                                           computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:invoice_advance_paid_amount])

      amount :reporting_invoice_advance_paid_amount, label: 'Advance Paid(Reporting Currency)', editable: false, visible: false,
                                                     can_visible_be_changed: false,
                                                     can_editable_be_changed: false,
                                                     computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_invoice_advance_paid_amount])

      # amount :po_invoice_adjusted_advance, label: "Current Adjustment", editable: true, visible: true, required: false
      # amount :po_invoice_adjusted_advance_tds, label: "Current Adjustment Tds", editable: true, visible: true, required: false

      amount :invoice_balance_due, label: 'Balance Payable', editable: false,
                                   can_editable_be_changed: false, visible: true,
                                   computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:invoice_balance_due])

      amount :reporting_invoice_balance_due, label: 'Balance Payable(Reporting Currency)', editable: false, visible: true,
                                             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_invoice_balance_due]),
                                             can_visible_be_changed: false, can_editable_be_changed: false
    end
  end

  # ATTACHMENTS
  section :attachments, associate_custom_fields: true do
    attachment :invoice_attachments, system_field: false, required: true
  end

  # VALIDATIONS
  validation validation_id: 'Invoice Date Cannot be Later than Due Date' do
    reference 'due_date'
    error_message 'Invoice Due Date must be After Invoice Date'
    rule Rules::Builder['due_date'].lt(entity: 'date')
  end

  #   validation validation_id: "Adjusted amount should be less than remaining adjustable amount" do
  #     reference 'adjusted_po_advance_payable_amount'
  #     error_message "Adjusted amount should be less than remaining adjustable amount"
  #     rule Rules::Builder['adjusted_po_advance_payable_amount'].lt(entity: "remaining_adjustable_advance")
  #   end

  validation validation_id: 'To date cannot be before From date' do
    reference 'transaction_service_period_to'
    error_message 'Transaction To date must be after From date'
    rule Rules::Builder['transaction_service_period_to'].lt(entity: 'transaction_service_period_from')
  end

  validation validation_id: 'Item Discount Cannot be greater than Item gross amount' do
    reference 'items.item_discount_amount'
    error_message 'Item Discount Amount Cannot be greater than Item Gross Amount'
    rule Rules::Builder['row.item_discount_amount'].gt(entity: 'row.item_gross_amount')
  end

  validation validation_id: 'Invoice Discount Cannot be greater than Invoice Gross Amount' do
    reference 'items_summary.invoice_discount_amount'
    error_message 'Invoice Discount Cannot be greater than Invoice Gross amount'
    rule Rules::Builder['items_summary.invoice_discount_amount'].gt(entity: 'items_summary.invoice_gross_amount')
  end

  validation validation_id: 'Item Qunatity Cannot be less then 0' do
    reference 'items.quantity'
    error_message 'Item cannot be less then or equal to 0'
    rule Rules::Builder['row.quantity'].lt(value: 0).or(Rules::Builder['row.quantity'].eq(value: 0))
  end

  validation validation_id: 'Item Qunatity Cannot be greater than Unbilled quantity' do
    reference 'items.quantity'
    error_message 'Item Qunatity Cannot be greater than Unbilled quantity'
    rule Rules::Builder['row.quantity'].gt(entity: 'row.unbilled_quantity')
  end

  # Add Validation so that user can not increase item quantity and user can not decrease quantity to zero
  # validation validation_id: "Invoice Discount Cannot be greater than Invoice Gross Amount" do
  #   reference 'items_summary.invoice_discount_amount'
  #   error_message "Invoice Discount Cannot be greater than Invoice Gross amount"
  #   rule Rules::Builder['items_summary.invoice_discount_amount'].gt(entity: "items_summary.invoice_gross_amount")
  # end

  # CONDITIONS
  condition condition_id: 'Policy should not be editable once unless in editable status' do
    reference :entity, :policy_id
    rule Rules::Builder[:invoice_status_id].eq_any(*InwardInvoiceStatus.ids_for(:open).map { |item| { value: item } })
    action :editable, true
    action :required, true
  end

  condition condition_id: 'Enable Bank Accounts > Swift / BIC Code for International Vendors' do
    reference :entity, 'vendor_bank_account_swift_code'
    rule Rules::Builder[:vendor_country_id_value].not_eq(value: 'India')
    action :visible, true
    action :required, true
  end

  condition condition_id: 'Disable Bank Accounts > IFSC Code for International Vendors' do
    reference :entity, 'vendor_bank_account_ifsc'
    rule Rules::Builder[:vendor_country_id_value].not_eq(value: 'India')
    action :visible, false
    action :required, false
  end

  # condition condition_id: "Base Currency non editable for Local vendor" do
  #   reference :entity, 'base_currency_id'
  #   rule Rules::Builder[:vendor_country_id_value].eq(value: 'India')
  #   action :editable, false
  # end

  condition condition_id: 'Disable advance adjustment if advance not paid' do
    reference :entity, 'advance_amount_required'
    rule Rules::Builder[:advance_paid].eq_any(value: true)
    action :editable, true
  end

  condition condition_id: 'Disable Vendor Location > No Location for International Vendors' do
    reference :entity, 'gstin_location_id'
    rule Rules::Builder[:vendor_country_id_value].not_eq(value: 'India')
    action :visible, false
    action :required, false
  end

  condition condition_id: 'Disable Vendor Gstin > No Gstin for International Vendors' do
    reference :entity, 'vendor_gstin'
    rule Rules::Builder[:vendor_country_id_value].not_eq(value: 'India')
    action :visible, false
    action :required, false
  end

  condition condition_id: 'Disable Vendor Pan > No Pan for International Vendors' do
    reference :entity, 'vendor_pan'
    rule Rules::Builder[:vendor_country_id_value].not_eq(value: 'India')
    action :visible, false
    action :required, false
  end

  condition condition_id: 'Disable RCM for International > Rcm for International Vendors' do
    reference :entity, 'rcm_enabled'
    rule Rules::Builder[:vendor_country_id_value].not_eq(value: 'India')
    action :visible, false
  end

  condition condition_id: 'Disable HSN/SAC for International > HSN/SAC for International Vendors' do
    reference :entity, 'items.hsn_sac'
    rule Rules::Builder[:vendor_country_id_value].not_eq(value: 'India')
    action :visible, false
  end

  condition condition_id: 'Disable Shipping address gstin for International' do
    reference :entity, 'shipping_address_gstin'
    rule Rules::Builder[:vendor_country_id_value].not_eq(value: 'India')
    action :visible, false
    action :required, false
  end

  condition condition_id: 'Disable Billing address gstin for International' do
    reference :entity, 'billing_address_gstin'
    rule Rules::Builder[:vendor_country_id_value].not_eq(value: 'India')
    action :visible, false
    action :required, false
  end

  condition condition_id: 'Disable item department > Item department not for Header Cost Allocation Items' do
    reference :entity, 'items.items_department_id'
    rule Rules::Builder[:cost_allocation_items].eq_any(value: true)
    action :visible, true
    action :required, true
    action :editable, true
  end

  condition condition_id: 'Enable item department > Item Cost Center for Header Cost Allocation Items' do
    reference :entity, 'department_id'
    rule Rules::Builder[:cost_allocation_items].eq_any(value: true)
    action :visible, false
    action :required, false
    action :editable, false
  end

  condition condition_id: 'Disable item Cost Center > Item Cost Center not for Header Cost Allocation Items' do
    reference :entity, 'items.items_cost_center_id'
    rule Rules::Builder[:cost_allocation_items].eq_any(value: true)
    action :visible, true
    action :required, true
    action :editable, true
  end

  condition condition_id: 'Enable item Cost Center > Item Cost Center for Header Cost Allocation Items' do
    reference :entity, 'cost_center_id'
    rule Rules::Builder[:cost_allocation_items].eq_any(value: true)
    action :visible, false
    action :required, false
    action :editable, false
  end

  condition condition_id: 'Hide Conversion Rate for indian currency' do
    reference :entity, 'conversion_rate'
    rule Rules::Builder[:base_currency_id].eq(entity: 'reporting_currency_id')
    action :visible, false
  end

  condition condition_id: 'Hide Roundoff for different currency' do
    reference :entity, 'items_summary.invoice_roundoff_amount'
    rule Rules::Builder[:base_currency_id].eq(value: Currency.id_for('INR').to_s).and(Rules::Builder[:reporting_currency_id].eq(value: Currency.id_for('INR').to_s))
    action :visible, true
  end

  condition condition_id: 'Hide Net Amount (Reporting Currency)' do
    reference :entity, 'items_summary.reporting_invoice_sub_total_amount'
    rule Rules::Builder[:base_currency_id].eq(entity: 'reporting_currency_id')
    action :visible, false
  end

  # condition condition_id: 'Hide PO advance (Reporting Currency)' do
  #   reference :entity, 'reporting_po_advance'
  #   rule Rules::Builder[:base_currency_id].eq(entity: 'reporting_currency_id')
  #   action :visible, false
  # end

  # condition condition_id: 'Hide prev adjusted PO advance (Reporting Currency)' do
  #   reference :entity, 'reporting_po_prev_adjusted_advance'
  #   rule Rules::Builder[:base_currency_id].eq(entity: 'reporting_currency_id')
  #   action :visible, false
  # end

  # condition condition_id: 'Hide current adjusted PO advance (Reporting Currency)' do
  #   reference :entity, 'reporting_adjusted_po_advance_payable_amount'
  #   rule Rules::Builder[:base_currency_id].eq(entity: 'reporting_currency_id')
  #   action :visible, false
  # end

  condition condition_id: 'Hide Reporting Balance Payable for Indian currency' do
    reference :entity, 'items_summary.reporting_invoice_balance_due'
    rule Rules::Builder[:base_currency_id].eq(entity: 'reporting_currency_id')
    action :visible, false
  end

  condition condition_id: 'Disable quantity selection for Service' do
    reference :entity, 'items.quantity'
    rule Rules::Builder['row.product_type_id_value'].eq(value: 'service')
    action :editable, false
  end

  # condition condition_id: "Disable discount selection for Service" do
  #   reference :entity, 'items.discount'
  #   rule Rules::Builder['row.product_type_id_value'].eq(value: "service")
  #   action :editable, false
  # end

  # condition condition_id: "Disable tds if advance is present" do
  #   reference :entity, 'tds_slab_id'
  #   rule Rules::Builder['document_advance.advance_amount_required'].eq(value: "true")
  #   action :editable, false
  # end

  # condition condition_id: "Discount Non editable for Service" do
  #   reference :entity, 'items.discount'
  #   rule Rules::Builder[:"items.product_type_id"].eq(value: '2')
  #   action :editable, false
  # end
end
