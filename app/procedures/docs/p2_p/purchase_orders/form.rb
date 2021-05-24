class Docs::P2P::PurchaseOrders::Form < Forms::API

  model PurchaseOrder

  meta(
    {
      created_by: {
        id: "{{record.user.id}}",
        name: "{{record.user.name}}",
        email: "{{record.user.email}}"
      }
    }
  )

  # LIQUID FORMULAE
  LIQUID_FORMULAE = {
    items: {
      item_gross_amount: "{{ row.rate | times: row.quantity | default: 0 | round: 2  }}",
      item_discount_amount:  "{% if form.discount_type_id == 1 %}{{ row.item_gross_amount | times: row.discount | divided_by: 100 | default: 0 | round: 2  }}{% else %}{{ row.discount | default: 0 }}{% endif %}",
      item_taxable_amount: "{{ row.item_gross_amount | minus: row.item_discount_amount | default: 0 | round: 2  }}",
      item_tax_amount: "{{ row.item_taxable_amount | times: row.tax_percentage | divided_by: 100 | default: 0 | round: 2  }}",
      item_tds_amount: "{% if row.tds_applicable == 'true' %}{{ row.item_taxable_amount | times: form.tds_percentage | divided_by: 100 | default: 0 | round: 2  }}{% else %}{{ 0 }}{% endif %}",
      item_net_amount: "{% if form.rcm_enabled == true %}{{ row.item_taxable_amount | default: 0 | round: 2 }}{% else %}{{ row.item_taxable_amount | plus: row.item_tax_amount | default: 0 | round: 2 }}{% endif %}",
      item_billable_amount:  "{{ row.item_taxable_amount| default: 0 | round: 2 }}",
        
        # CONVERTED VALUES
      reporting_item_gross_amount: "{{ row.item_gross_amount | times: form.conversion_rate | default: 0 | round: 2}}",
      reporting_item_discount_amount: " {{ row.item_discount_amount | times: form.conversion_rate | default: 0 | round: 2}}",
      reporting_item_taxable_amount: "{{ row.item_taxable_amount | times: form.conversion_rate | default: 0 | round: 2}}",
      reporting_item_tax_amount: "{{ row.item_tax_amount | times: form.conversion_rate | default: 0 | round: 2  }}",
      reporting_item_tds_amount: "{{ row.item_tds_amount | times: form.conversion_rate | default: 0 | round: 2  }}",
      reporting_item_net_amount: "{{ row.item_net_amount | times: form.conversion_rate | default: 0 | round: 2  }}",
      reporting_item_billable_amount: " {{ row.item_billable_amount | times: form.conversion_rate | default: 0 | round: 2  }}"
    },

    # PURCHASE ORDER SUMMARY
    summary: {
      gross_amount: "{% assign gross_amount = 0 %}{% for item in form.items %}{% if item._destroy == true %}{% continue %}{% else %}{% assign gross_amount = gross_amount | plus: item.item_gross_amount %}{% endif %}{% endfor %}{{ gross_amount | default: 0 | round: 2 }}",
      discount_amount: "{% assign discount_amount = 0 %}{% for item in form.items %}{% if item._destroy == true %}{% continue %}{% else %}{% assign discount_amount = discount_amount | plus: item.item_discount_amount %}{% endif %}{% endfor %}{{ discount_amount | default: 0 | round: 2 }}",
      taxable_amount: "{{ form.gross_amount | minus: form.discount_amount | default: 0 | round: 2}}",
      tax_amount: "{% assign tax_amount = 0 %}{% for item in form.items %}{% if item._destroy == true %}{% continue %}{% else %}{% assign tax_amount = tax_amount | plus: item.item_tax_amount %}{% endif %}{% endfor %}{{ tax_amount  | default: 0 | round: 2}}",
      freight_amount: "{{ form.freight_amount | default: 0 | round: 2}}",
      # NET AMOUNT
      sub_total_amount: "{% assign inv_sub_total_amount = form.gross_amount | minus: form.discount_amount | plus: form.tax_amount | plus: form.freight_amount | round: 2 %}{% if form.rcm_enabled == true  %}{{ inv_sub_total_amount | minus: form.tax_amount | default: 0 | round: 2}}{% else %}{{ inv_sub_total_amount | default: 0 | round: 2 }}{% endif %}",
      
      paid_outside_amount: "{{ form.paid_outside_amount | default: 0 | round: 2}}",
      tds_amount: "{% assign tds_amount = 0 %}{% for item in form.items %}{% if item._destroy == true %}{% continue %}{% else %}{% assign tds_amount = tds_amount | plus: item.item_tds_amount %}{% endif %}{% endfor %}{{ tds_amount  | default: 0 | ceil}}",
      
      #### net payable amount 
      roundoff_amount: "{% assign net_total_amount = form.sub_total_amount | minus: form.paid_outside_amount | minus: form.tds_amount %}{% assign round_amount = net_total_amount | round %}{% assign amount = round_amount | minus: net_total_amount %}{% if form.base_currency != '1' %}{% assign amount = 0 %}{% endif %}{{ amount | default: 0 | round: 2 }}",
      total_amount: "{{ form.sub_total_amount | plus: form.roundoff_amount | minus: form.tds_amount | minus: form.paid_outside_amount | default: 0 | round: 2}}",
      
      #### net payable amount has roundoff value added
      net_total_amount: "{% if form.base_currency != '1' %}{{ form.total_amount | default: 0 | round: 2 }}{% else %}{{ form.total_amount | default: 0 | round }}{% endif %}",
      advance_paid_amount: "{{ form.advance_paid_amount | default: 0 | round: 2}}",
      balance_due: "{{ form.total_amount | minus: form.advance_paid_amount | default: 0 | round: 2}}",

      # CONVERTED VALUES
      reporting_gross_amount: "{{ form.gross_amount | times: form.conversion_rate | default: 0 | round: 2}}",
      reporting_discount_amount: "{{ form.discount_amount | times: form.conversion_rate | default: 0 | round: 2}}",
      reporting_taxable_amount: "{{ form.taxable_amount | times: form.conversion_rate | default: 0 | round: 2}}",
      reporting_tax_amount: "{{ form.tax_amount | times: form.conversion_rate | default: 0 | round: 2}}",
      reporting_freight_amount: "{{ form.freight_amount | times: form.conversion_rate | default: 0 | round: 2}}",
      reporting_sub_total_amount: "{{ form.sub_total_amount | times: form.conversion_rate | default: 0 | round: 2}}",
      reporting_paid_outside_amount: "{{ form.paid_outside_amount | times: form.conversion_rate | default: 0 | round: 2}}",
      reporting_tds_amount: "{{ form.tds_amount | times: form.conversion_rate | default: 0 | round: 2}}",
      reporting_roundoff_amount: "{% assign amount = form.reporting_sub_total_amount | round %}{% assign amount = amount | minus: form.reporting_sub_total_amount %}{% if form.base_currency != '1' %}{% assign amount = 0 %}{% endif %}{{ amount | default: 0 | round: 2}}",
      # reporting_total_amount: "{% assign amount = form.reporting_sub_total_amount | plus: form.reporting_roundoff_amount %}{% if form.base_currency != '1' %}{% assign amount = form.reporting_sub_total_amount %}{% endif %}{{ amount | default: 0 | round: 2 }}",
      reporting_total_amount: "{{ form.total_amount | times: form.conversion_rate | default: 0 | round: 2}}",
      
      reporting_net_total_amount: "{{ form.net_total_amount | times: form.conversion_rate | default: 0 | round: 2}}",
      reporting_advance_paid_amount: "{{ form.advance_paid_amount | times: form.conversion_rate | default: 0 | round: 2}}",
      reporting_balance_due: "{{ form.balance_due | times: form.conversion_rate | default: 0 | round: 2}}"
    }
  }

  # PURCHASE ORDER STATUS
  section :status do
    lookup :purchase_order_status_id,
           choices_scope: Choices[:enum].(PurchaseOrderStatus),
           required: false, editable: false,
           default_value: PurchaseOrderStatus.id_for(:open),
           can_editable_be_changed: false
  end

  # PURCHASE ORDER DETAILS
  section :purchas_order_details, title: "ORDER Details", associate_custom_fields: true do
    auto_number :po_number,
                label: "Sequence Number",
                editable: false,
                sequence: { prefix: "PO-", start_at: '00001' }

    date :created_at,
         label: "Purchase Order Date",
         computed: Forms::Compute::Form('{{ form.created_at  | date: "%Y-%m-%d" }}'),
         required: true, editable: false
         # restriction: 'not_in_the_future'

    lookup :payment_term_id,
           choices_scope: Choices[:lookup].('payment_terms'),
           label: "Payment Term",
           visible: true, required: true, editable: true

    number :payment_term_days,
           label: "Payment Term Days",
           computed: Forms::Compute::Lookup('payment_term_id', '{{record.days_after | default: 0 }}'),
           visible: false

    date :delivery_date,
         computed: Forms::Compute::Form('{% assign assigne_days = form.payment_term_days | times: 86400 %}{% assign calculated_date = form.date | date: "%s" | plus: assigne_days %}{{ calculated_date  | date: "%Y-%m-%d" }}'),
         visible: true, required: true, editable: true

    switch :cost_allocation_items, label: 'Cost Allocation (Item Level)', required: true, default_value: false
  end

  # ACCOUNTING DETAILS
  section :accounting_details, title: "Accounting Details", associate_custom_fields: true do
    lookup :policy_id,
           choices_scope: Choices[:lookup].('policies'),
           required: true, editable: false

    lookup :department_id, label: "Department", editable: true, visible: true, required: true, choices_scope: Choices[:lookup].('departments') #, editable: false, visible: false
    lookup :cost_center_id, label: "Cost Center", editable: true, visible: true, required: true, choices_scope: Choices[:lookup].('cost_centers')
    dropdown :discount_type_id, label: "Discount Type", editable: true, visible: true, required: true, choices_scope: Choices[:list].({ id: 1, name: 'Percentage' }, { id: 2, name: 'Amount' }), default_value: 1
    dropdown :gst_type_id, label: "Tax Type", editable: true, visible: true, choices_scope: Choices[:list].(*TaxType.all.map { |v| { id: v.id, name: v.name } })

    date :conversion_date, label: "Conversion Date", editable: false, visible: true, computed: Forms::Compute::Form('{{form.created_at}}')
    lookup :reporting_currency_id, label: "Reporting Currency", editable: false, visible: true, can_editable_be_changed: false
    lookup :base_currency_id, label: "Base Currency", choices_scope: Choices[:lookup].('form_currencies'), visible: true, editable: true
    number :conversion_rate, editable: true, format: 'decimal', default_value: 1, computed: Forms::Compute::Lookup('base_currency', '{{ record.currency_conversion_rate }}'), visible: true
  end

  # VENDOR DETAILS
  section :vendor_details, title: "Vendor Details", associate_custom_fields: true do
    lookup :vendor_id, label: "Vendor", choices_scope: Choices[:lookup].('vendors'), required: true, editable: false,
           can_editable_be_changed: false, can_be_disabled: false, can_required_be_changed: false, can_visible_be_changed: false

    lookup :vendor_trade_name, label: 'Vendor Trade Name', editable: false, visible: true, computed: Forms::Compute::Lookup('vendor_id', '{{record.business_name}}', assignments: { created_by_id: "{{meta.user_id}}" })
    text :vendor_country, editable: false, visible: true

    text :vendor_sequence_id, "Vendor ID", editable: false, computed: Forms::Compute::Lookup('vendor_id', '{{record.vendor_id}}')
    lookup :gstin_location_id, label: 'Vendor Location', choices_scope: Choices[:lookup].('vendor_locations'), # todo - condition to hide for international
           filters: Rules::Builder[:vendor_id].eq(entity: :vendor_id)
    text :vendor_gstin, "Vendor GSTIN", editable: false, computed: Forms::Compute::Lookup('gstin_location_id', '{{record.gstin}}') # todo - condition
    text :vendor_pan, "Vendor PAN", editable: false # todo - add condition

    lookup :bank_account_id, label: "Bank Account", choices_scope: Choices[:lookup].('vendor_bank_accounts'),
           filters: Rules::Builder[:account_owner_id].eq(entity: 'vendor_id').and(Rules::Builder[:account_owner_type].eq(value: 'YesBankVendor')),
           editable: true, visible: true, required: true


    # need to add these fields as system fields
    text :vendor_bank_account_number, editable: false, can_editable_be_changed: false, computed: Forms::Compute::Lookup('bank_account_id', '{{record.account_number}}')
    text :vendor_bank_account_ifsc, editable: false, required: true, can_editable_be_changed: false, computed: Forms::Compute::Lookup('bank_account_id', '{{record.ifsc}}')
    text :vendor_bank_account_swift_code, editable: false, visible: false, required: false, can_editable_be_changed: false, computed: Forms::Compute::Lookup('bank_account_id', '{{record.swift_code}}')
  end

  # BILLING ADDRESS
  section :billing_address do
    lookup :location_id, label: 'Company Address', choices_scope: Choices[:lookup].('locations'),
           filters: Rules::Builder['billable_location'].true, required: true
    # text :name, editable: false, computed: Forms::Compute::Lookup('location_id', '{{record.gstin}}')
    # text :gstin, editable: false, computed: Forms::Compute::Lookup('location_id', '{{record.name}}')
    large_text :billing_address, computed: Forms::Compute::Lookup('location_id', '{{record.address}}')
  end

  # SHIPPING ADDRESS
  section :shipping_address do
    lookup :delivery_location_id, label: 'Delivery Address', choices_scope: Choices[:lookup].('locations'),
           filters: Rules::Builder['shippable_location'].true, required: true
    # text :name, editable: false, computed: Forms::Compute::Lookup('delivery_location_id', '{{record.gstin}}')
    # text :gstin, editable: false, computed: Forms::Compute::Lookup('delivery_location_id', '{{record.name}}')
    large_text :shipping_address, computed: Forms::Compute::Lookup('delivery_location_id', '{{record.address}}')
  end

  # PURCHASE ORDER ITEMS
  section :items, associate_custom_fields: true do
    table :items, min_items: 1, populate_if_empty: PurchaseOrderItem do
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
      text :item_number, label: "Item Code", editable: false, 
        computed: Forms::Compute::Lookup('items.inventory_line_item_id', '{{record.item_number}}')

      lookup :product_type_id, label: "Product Type", choices_scope: Choices[:enum].(ProductType), computed: Forms::Compute::Lookup('items.inventory_line_item_id', '{{record.product_type_id}}'), editable: false, required: true, visible: true

      lookup :items_department_id, label: "Department", editable: false, visible: false, required: false, choices_scope: Choices[:lookup].('departments')
      lookup :items_cost_center_id, label: "Cost Center", editable: false, visible: false, required: false, choices_scope: Choices[:lookup].('cost_centers')

      lookup :category_id, label: "Category", required: true, visible: true, editable: true, choices_scope: Choices[:lookup].('categories'), computed: Forms::Compute::Lookup('items.inventory_line_item_id', '{{record.category_id}}')

      text :gl_code, label: "GL Code", editable: false, visible: false, 
        computed: Forms::Compute::Lookup('items.category_id', '{{record.gl_code}}')
      
      text :hsn_sac, label: "HSN/SAC", editable: true, visible: true,
        computed: Forms::Compute::Lookup('items.inventory_line_item_id', '{{record.hsn_sac}}')

      lookup :tds_applicable, visible: true, editable: false, can_editable_be_changed: false, can_visible_be_changed: false,
             computed: Forms::Compute::Lookup('items.inventory_line_item_id', '{{ record.tds_applicable }}')

      number :quantity, label: "Quantity", editable: true, visible: true, required: true, min_value: 1, default_value: 1 # todo - condition

      dropdown :unit_of_measurement, label: "Unit of Measurement",
               choices_scope: Choices[:list].(*Unit.all.map { |v| { id: v.value, name: v.name } }),
               required: true, editable: true, visible: true,
               computed: Forms::Compute::Lookup('items.inventory_line_item_id', '{{record.unit_of_measurement}}')

      amount :item_rate, label: "Item Rate", visible: true,
             computed: Forms::Compute::Lookup('items.inventory_line_item_id', '{{ record.rate | default: 0 | round: 2 }}')

      amount :rate, label: "Rate", can_editable_be_changed: false, can_visible_be_changed: false, required: true, visible: true, editable: true,
             computed: Forms::Compute::Form('{{ row.item_rate | divided_by: form.conversion_rate | round: 2 }}')

      # gross_amount = rate x quantity
      amount :item_gross_amount, label: 'Item Gross Amount', editable: false, visible: false,
             can_visible_be_changed: false, can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:item_gross_amount])

      amount :reporting_item_gross_amount, label: 'Item Gross Amount(Reporting Currency)', editable: false, visible: false,
             can_visible_be_changed: false, can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:reporting_item_gross_amount])

      number :discount, visible: true, editable: true, default_value: 0

      # discount_amount = gross_amount x discount / 100
      amount :item_discount_amount, label: 'Item Discount Amount', editable: false, visible: false, can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:item_discount_amount])

      amount :reporting_item_discount_amount, label: 'Item Discount Amount(Reporting Currency)', editable: false, visible: false,
             can_visible_be_changed: false, can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:reporting_item_discount_amount])

      # taxable_amount = gross_amount - discount_amount
      amount :item_taxable_amount, label: 'Item Taxable Amount', editable: false, visible: false, can_editable_be_changed: false,
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

      amount :item_tds_amount, label: 'Tds Amount', editable: false, visible: false,
             can_editable_be_changed: false, can_visible_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:item_tds_amount])

      amount :reporting_item_tds_amount, label: 'Tds Amount(Reporting Currency)', editable: false, visible: false,
             can_visible_be_changed: false, can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:reporting_item_tds_amount])

      amount :item_net_amount, label: "Net Amount", editable: false, visible: true,
             can_editable_be_changed: false, can_visible_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:item_net_amount])

      amount :reporting_item_net_amount, label: "Net Amount(Reporting Currency)", editable: false, visible: false,
             can_visible_be_changed: false, can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:reporting_item_net_amount])

      amount :item_billable_amount, label: "Billable Amount", editable: false, visible: false,
             can_editable_be_changed: false, active: false, can_visible_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:item_billable_amount])

      amount :reporting_item_billable_amount, label: "Billable Amount(Reporting Currency)", editable: false, visible: false,
             can_visible_be_changed: false, can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:reporting_item_billable_amount])
    end
  end

  # PURCHASE ORDER ITEMS SUMMARY
  section :summary do
    summary :items_summary do
      amount :gross_amount, label: 'Gross Amount', editable: false, visible: true,
             can_editable_be_changed: false,
             can_visible_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:gross_amount])

      amount :reporting_gross_amount, label: 'Gross Amount(Reporting Currency)', editable: false, visible: false,
             can_visible_be_changed: false,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_gross_amount])

      amount :total_line_item_discount_amount, label: 'Total LineItem Discount Amount', editable: false,
             can_editable_be_changed: false, visible: false, active: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:total_line_item_discount_amount])

      amount :overall_discount_amount, label: 'Overall Discount Amount', editable: true, visible: false,
             can_editable_be_changed: false, active: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:overall_discount_amount])

      amount :discount_amount, label: "Total Discount", visible: true,
             editable: false, can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:discount_amount])

      amount :reporting_discount_amount, editable: false, visible: false,
             can_visible_be_changed: false, label: "Total Discount ( Reporting Currency )",
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_discount_amount])

      amount :taxable_amount, label: 'Taxable Amount', editable: false, visible: false,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:taxable_amount])

      amount :reporting_taxable_amount, label: 'Taxable Amount(Reporting Currency)', editable: false, visible: false,
             can_editable_be_changed: false,
             can_visible_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_taxable_amount])

      amount :tax_amount, label: 'Tax Amount', editable: false, visible: true,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:tax_amount])

      amount :reporting_tax_amount, label: 'Tax Amount(Reporting Currency)', editable: false, visible: false,
             can_visible_be_changed: false,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_tax_amount])

      amount :freight_amount, label: "Freight",
             default_value: 0, visible: true, editable: true,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:freight_amount])

      amount :reporting_freight_amount, label: "Freight(Reporting Currency)", editable: false, visible: false,
             can_visible_be_changed: false,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_freight_amount])

      amount :sub_total_amount, label: 'Net Amount', editable: false, visible: true,
             can_visible_be_changed: false,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:sub_total_amount]) # todo - changd name

      amount :reporting_sub_total_amount, label: 'Net Amount(Reporting Currency)', editable: false, visible: true,
             can_visible_be_changed: false,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_sub_total_amount]) # todo - changd name

      lookup :tds_slab_id, choices_scope: Choices[:lookup].('tds_slabs'), visible: true # todo - condition when reporting currency is in INR

      number :tds_percentage, internal: true, editable: false, visible: true, # todo - condition when reporting currency is in INR
             can_editable_be_changed: false,
             computed: Forms::Compute::Lookup('items_summary.tds_slab_id', '{{record.tds}}')

      amount :tds_amount, label: 'Tds Amount', editable: false, visible: true, # todo - condition when reporting currency is in INR
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:tds_amount])

      amount :reporting_tds_amount, label: 'Tds Amount(Reporting Currency)', editable: false, visible: false,
             can_visible_be_changed: false,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_tds_amount])

      amount :paid_outside_amount, label: "Advance Paid",
             default_value: 0, visible: true, editable: true

      amount :reporting_paid_outside_amount, label: "Advance Paid(Reporting Currency)", editable: false, visible: false,
             can_visible_be_changed: false,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_paid_outside_amount])

      amount :roundoff_amount, label: 'Roundoff Amount', visible: true, editable: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:roundoff_amount]) # todo - changd name

      amount :reporting_roundoff_amount, label: 'Roundoff Amount(Reporting Currency)', editable: false, visible: false,
             can_visible_be_changed: false,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_roundoff_amount]) # todo - changd name

      amount :total_amount, label: 'Total Amount', editable: false, visible: false,
             can_editable_be_changed: false,
             can_visible_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:total_amount])

      amount :reporting_total_amount, label: 'Total Amount(Reporting Currency)', editable: false, visible: false,
             can_visible_be_changed: false,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_total_amount])

      amount :net_total_amount, label: "Net Payable", editable: false, visible: false,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:net_total_amount])

      amount :reporting_net_total_amount, label: "Net Payable (Reporting Currency)", editable: false, visible: false,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_net_total_amount])

      amount :advance_paid_amount, label: "Total Partial-Payment",
             default_value: 0, editable: false, visible: true,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:advance_paid_amount])

      amount :reporting_advance_paid_amount, label: "Total Partial-Payment(Reporting Currency)", editable: false, visible: false,
             can_visible_be_changed: false,
             can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_advance_paid_amount])

      amount :balance_due, label: "Balance Payable", editable: false,
             can_editable_be_changed: false, visible: true,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:balance_due])

      amount :reporting_balance_due, label: "Balance Payable(Reporting Currency)", editable: false, visible: true,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_balance_due]),
             can_visible_be_changed: false, can_editable_be_changed: false
    end
  end

  # ATTACHMENTS
  section :attachments, associate_custom_fields: true do
    attachment :attachments, system_field: false
  end
  # If reporting currency & base currency are same, then hide conversion_rate

  # VALIDATIONS
  validation validation_id: "Order Date Cannot be Later than Delivery Date" do
    reference 'due_date'
    error_message "Order Date Cannot be Later than Delivery Date"
    rule Rules::Builder['due_date'].lt(entity: "date")
  end

  # validation validation_id: "Conversion Rate must be greater than 0" do
  #   reference 'conversion_rate'
  #   error_message "Conversion Rate must be greater than 0"
  #   rule Rules::Builder['conversion_rate'].gteq(value: 0.0)
  # end

  # CONDITIONS
  condition condition_id: "Policy should not be editable once unless in editable status" do
    reference :entity, :policy_id
    rule Rules::Builder[:status_id].eq_any(*PurchaseOrderStatus.ids_for(:open).map { |item| { value: item } })
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
  #   reference :entity, 'items_summary.tds_amount'
  #   rule Rules::Builder[:vendor_country].not_eq(value: 'India')
  #   action :visible, false
  #   action :required, false
  # end

  condition condition_id: "Disable RCM for International > Rcm for International Vendors" do
    reference :entity, 'rcm_enabled'
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :visible, false
  end

  condition condition_id: "Base Currency non editable for Indian vendor" do
    reference :entity, 'base_currency'
    rule Rules::Builder[:vendor_country].eq(value: 'India')
    action :editable, false
  end

  # condition condition_id: "Hide Conversion Rate for indian currency" do
  #   reference :entity, 'conversion_rate'
  #   rule Rules::Builder[:reporting_currency].eq(entity: :base_currency)
  #   action :visible, false
  # end

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

  # condition condition_id: "Hide Reporting Roundoff for different currency" do
  #   reference :entity, 'items_summary.reporting_roundoff_amount'
  #   rule Rules::Builder[:base_currency].eq(value: '1')
  #   action :visible, false
  # end

  condition condition_id: "Hide Conversion Rate for indian currency" do
    reference :entity, 'conversion_rate'
    rule Rules::Builder[:base_currency].eq(value: '1')
    action :visible, false
  end

  condition condition_id: "Hide Roundoff for different currency" do
    reference :entity, 'items_summary.roundoff_amount'
    rule Rules::Builder[:base_currency].not_eq(value: '1')
    action :visible, false
  end

  condition condition_id: "Hide Net Amount (Reporting Currency)" do
    reference :entity, 'items_summary.reporting_sub_total_amount'
    rule Rules::Builder[:base_currency].eq(value: '1')
    action :visible, false
  end

  condition condition_id: "Hide Reporting Balance Payable for indian currency" do
    reference :entity, 'items_summary.reporting_balance_due'
    rule Rules::Builder[:base_currency].eq(value: '1')
    action :visible, false
  end

  # predict 'policy_id', with: :vendor_id
  # predict 'department_id', with: [:vendor_id, :policy_id]
  # predict 'location_id', with: [:vendor_id, :policy_id]
  # predict 'cost_center_id', with: [:vendor_id, :policy_id]
  # predict 'items.inventory_line_item_id', with: [:vendor_id, :policy_id]

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

end