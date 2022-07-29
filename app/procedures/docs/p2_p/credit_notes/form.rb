class Docs::P2P::CreditNotes::Form < Forms::API

  model CreditNote

  meta ->(record) {
    {
      created_by: {
        id: '{{record.creator.id}}',
        name: '{{record.creator.name}}',
        email: '{{record.creator.email}}'
      }
    }
  }

  # LIQUID FORMULAE
  LIQUID_FORMULAE = {
    items: {
      cn_original_taxable_amount: '{{row.original_rate | times: row.original_quantity | round: 2}}',
      rate: "{% unless row.credit_note_item_type_id == '#{CreditNoteItemType.id_for(:price_drop)}' %}{{row.original_rate | round: 2}}{% else %}{{ row.rate | round: 2 | at_least: 0 | at_most: row.original_rate | default: 0 }}{% endunless %}",
      quantity: "{% unless row.credit_note_item_type_id == '#{CreditNoteItemType.id_for(:qty_change)}' %}{{ row.original_quantity }}{% else %}{{ row.quantity | round: 2 | at_least: 0 | at_most: row.original_quantity | default: 0 }}{% endunless %}",
      cn_revised_taxable_amount: "{% if row.credit_note_item_type_id == '#{CreditNoteItemType.id_for(:gst_change)}' %}{{ 0 }}{% else %}{{row.rate | times: row.quantity | round: 2}}{% endif %}",
      original_item_tax_amount: '{{row.cn_original_taxable_amount | times: row.original_tax_percentage | divided_by: 100 | round: 2 | default: 0}}',
      item_tax_amount: "{% if row.credit_note_item_type_id == '#{CreditNoteItemType.id_for(:gst_change)}' %}{% assign tax_diff = row.original_tax_percentage | minus: row.revised_tax_percentage | default: 0 %}{{ row.cn_original_taxable_amount | times: tax_diff | divided_by: 100 }}{% else %}{{row.cn_taxable_amount | times: row.revised_tax_percentage | divided_by: 100 | round: 2 | default: 0}}{% endif %}",
      total_amount: "{% if row.credit_note_item_type_id == '#{CreditNoteItemType.id_for(:gst_change)}' %}{% assign tax_diff = row.original_tax_percentage | minus: row.revised_tax_percentage | default: 0 %}{{ row.cn_original_taxable_amount | times: tax_diff | divided_by: 100 }}{% else %}{{ row.cn_taxable_amount | plus: row.item_tax_amount | round: 2 | default: 0 }}{% endif %}"
    },
    summary: {
      cn_gross_receivable_amount: '{% assign gross_amount = 0 %}{% for item in form.items %}{% if item._destroy == true %}{% continue %}{% else %}{% assign gross_amount = gross_amount | plus: item.cn_taxable_amount %}{% endif %}{% endfor %}{{ gross_amount | default: 0 | round: 2 }}',
      cn_tax_amount: '{% assign gross_amount = 0 %}{% for item in form.items %}{% if item._destroy == true %}{% continue %}{% else %}{% assign gross_amount = gross_amount | plus: item.item_tax_amount %}{% endif %}{% endfor %}{{ gross_amount | default: 0 | round: 2 }}',
      cn_tds_amount: "{% assign tds_amount = 0 %}{% for item in form.items %}{% if item._destroy == true or item.tds_applicable == 'false' %}{% continue %}{% else %}{% assign item_cn_tds_amount = item.cn_taxable_amount | times: form.cn_tds_rate | divided_by: 100.00 | default: 0 | round: 2 %}{% assign tds_amount = tds_amount | plus: item_cn_tds_amount %}{% endif %}{% endfor %}{{ tds_amount | default: 0 | ceil }}",
      cn_net_receivable_amount: "{{ form.cn_gross_receivable_amount | plus: form.cn_tax_amount | minus: form.cn_tds_amount | plus: form.cn_roundoff_amount | default: 0 | round: 2 }}",
      cn_roundoff_amount: "{% assign net_amount = form.cn_gross_receivable_amount | plus: form.cn_tax_amount | minus: form.cn_tds_amount | default: 0 | round: 2 %}{% assign round_amount = net_amount | round %}{% assign amount = round_amount | minus: net_amount %}{% if form.base_currency_id == '#{Currency.id_for('INR')}' and form.reporting_currency_id == '#{Currency.id_for('INR')}' %}{{ amount | default: 0 | round: 2 }}{% endif %}",
      cn_previously_adjusted_amount: '{{form.cn_previously_adjusted_amount | default: 0 | round: 2}}',
      net_adjusted_amount: '{{form.cn_net_receivable_amount| minus: form.cn_previously_adjusted_amount | default: 0 | round: 2}}',

      reporting_cn_gross_receivable_amount: '{% assign conv_rate = form.conversion_rate | round: 5 %}{{ form.cn_gross_receivable_amount | times: conv_rate | default: 0 | round: 2}}',
      reporting_cn_tax_amount: '{% assign conv_rate = form.conversion_rate | round: 5 %}{{ form.reporting_cn_tax_amount | times: conv_rate | default: 0 | round: 2}}',
      reporting_cn_net_receivable_amount: '{% assign conv_rate = form.conversion_rate | round: 5 %}{{ form.reporting_cn_net_receivable_amount | times: conv_rate | default: 0 | round: 2}}',
      reporting_cn_previously_adjusted_amount: '{% assign conv_rate = form.conversion_rate | round: 5 %}{{ form.reporting_cn_previously_adjusted_amount | times: conv_rate | default: 0 | round: 2}}',
      reporting_net_adjusted_amount: '{% assign conv_rate = form.conversion_rate | round: 5 %}{{ form.reporting_net_adjusted_amount | times: conv_rate | default: 0 | round: 2}}',

    }
  }

  section :status do
    lookup :status_id,
           choices_scope: Choices[:lookup].('credit_note_statuses'),
           required: false, editable: false,
           default_value: CreditNoteStatus.id_for(:draft),
           can_editable_be_changed: false
  end

  section :credit_note_details, title: 'Credit Note Details', associate_custom_fields: true do
    auto_number :sequence_id, label: 'Sequence Number', editable: false, visible: true, sequence: { prefix: 'CN', start_at: '00001' }
    text :credit_note_number, label: 'Credit Note Number', required: true, unique: true
    date :credit_note_date,
         label: 'Credit Note Date',
         computed: Forms::Compute::Form('{{ form.date | default: "now" | date: "%Y-%m-%d" }}'),
         required: true, editable: true, visible: true,
         restriction: 'not_in_the_future'
    date :created_at, label: 'Created At', required: false, editable: false
    lookup :user_id, label: 'Created By', required: false, editable: false, choices_scope: Choices[:lookup].('users')
    lookup :department_id, label: 'Department', required: false, editable: false, choices_scope: Choices[:lookup].('departments')
    lookup :cost_center_id, label: 'Cost Center', required: false, editable: false, choices_scope: Choices[:lookup].('cost_centers')
    lookup :policy_id, label: 'Policy', required: true, editable: false, choices_scope: Choices[:lookup].('policies')
    large_text :narration, label: 'Narration', visible: true
    lookup :reporting_currency_id, label: 'Reporting Currency', choices_scope: Choices[:lookup].('currencies'), visible: true, editable: false, can_editable_be_changed: false
    lookup :base_currency_id, label: 'Base Currency', choices_scope: Choices[:lookup].('currencies'), visible: true, editable: false
    number :conversion_rate, editable: false, format: 'decimal', max_decimal_places: 5, default_value: 1, computed: Forms::Compute::Lookup('base_currency_id', '{{ record.currency_conversion_rate }}', assignments: {conversion_date: '{{form.conversion_date}}', to_currency: '{{form.reporting_currency_id}}'}), visible: true, editable: false
  end

  section :vendor_details, associate_custom_fields: true do
    lookup :vendor_id, label: 'Vendor', choices_scope: Choices[:lookup].('vendors'), required: true, editable: false,
           can_editable_be_changed: false, can_be_disabled: false, can_required_be_changed: false, can_visible_be_changed: false
    lookup :vendor_trade_name, label: 'Vendor Trade Name', editable: false, visible: true, computed: Forms::Compute::Lookup('vendor_id', '{{record.business_name}}', assignments: { created_by_id: '{{meta.user_id}}' })
    text :vendor_sequence_id, 'Vendor ID', editable: false, computed: Forms::Compute::Lookup('vendor_id', '{{record.vendor_id}}')
    text :vendor_pan, 'Vendor PAN', editable: false, visible: true
    lookup :gstin_location_id, label: 'Vendor Location', choices_scope: Choices[:lookup].('vendor_locations'),
           filters: Rules::Builder[:vendor_id].eq(entity: :vendor_id), editable: false
    text :vendor_gstin, 'Vendor GSTIN', editable: false, computed: Forms::Compute::Lookup('gstin_location_id', '{{record.gstin}}'), visible: true
    lookup :vendor_country_id, editable: false, visible: true, choices_scope: Choices[:lookup].('countries')
  end

  section :billing_address do
    lookup :billing_location_id, label: 'Billing Address', choices_scope: Choices[:lookup].('locations', assignments: { form: true }),
           filters: Rules::Builder['billable_location'].true, required: true, editable: false
    text :billing_address_name, label: 'Name', editable: false, computed: Forms::Compute::Lookup('billing_location_id', '{{record.name}}')
    text :billing_address_gstin, label: 'Gstin', editable: false, computed: Forms::Compute::Lookup('billing_location_id', '{{record.gstin}}')
    large_text :billing_address, computed: Forms::Compute::Lookup('billing_location_id', '{{record.address}}')
  end

  section :shipping_address do
    lookup :shipping_location_id, label: 'Shipping Address', choices_scope: Choices[:lookup].('locations', assignments: { form: true }),
           filters: Rules::Builder['shippable_location'].true, required: true, editable: false
    text :shipping_address_name, label: 'Name', editable: false, computed: Forms::Compute::Lookup('shipping_location_id', '{{record.name}}')
    text :shipping_address_gstin, label: 'Gstin', editable: false, computed: Forms::Compute::Lookup('shipping_location_id', '{{record.gstin}}')
    large_text :shipping_address, computed: Forms::Compute::Lookup('shipping_location_id', '{{record.address}}')
  end

  section :items, associate_custom_fields: true do
    table :items, min_items: 1, populate_if_empty: CreditNoteItem do
      number :id, visible: false, editable: false, internal: true, can_visible_be_changed: false, can_editable_be_changed: false
      lookup :credit_note_item_type_id, label: 'CN type',
             can_visible_be_changed: false,
             can_editable_be_changed: false,
             choices_scope: Choices[:lookup].('credit_note_item_types'),
             required: true, editable: true, visible: true
      lookup :invoice_item_id, label: 'Item',
             can_visible_be_changed: false,
             can_editable_be_changed: false,
             choices_scope: Choices[:lookup].('items'),
             required: false, editable: false, visible: false,
             can_editable_be_changed: false
      lookup :item_id, label: 'Item',
             can_visible_be_changed: false,
             can_editable_be_changed: false,
             choices_scope: Choices[:lookup].('items'),
             required: false, editable: false, visible: true,
             can_editable_be_changed: false
      text :item_number, label: 'Item Code', editable: false, can_editable_be_changed: false,
           computed: Forms::Compute::Lookup('items.invoice_item_id', '{{record.item_number}}')
      text :comment, label: 'Comment', editable: true, visible: true, required: false
      amount :original_quantity, label: 'Original Quantity', can_editable_be_changed: false,
             editable: false, visible: true
      amount :quantity, label: 'Credit Note Quantity',
             editable: true, visible: true, computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:quantity])
      amount :original_rate, label: 'Original Rate', editable: false, required: false, visible: true, can_editable_be_changed: false
      amount :rate, label: 'Credit Note Rate', editable: false, required: false, visible: true, computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:rate])
      amount :cn_original_taxable_amount, label: 'Original Taxable Amount', editable: false, required: false, visible: true, computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:cn_original_taxable_amount]), can_editable_be_changed: false
      amount :cn_taxable_amount, label: 'Credit Note Taxable Amount', editable: false, required: false, visible: true, computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:cn_revised_taxable_amount])
      lookup :tds_applicable, visible: true, editable: false, can_editable_be_changed: false, can_visible_be_changed: false,
             choices_scope: Choices[:list].({ id: true, name: 'true' }, { id: false, name: 'false' }),
             computed: Forms::Compute::Lookup('items.invoice_item_id', '{{ record.tds_applicable }}')
      lookup :original_tax_rate_id, label: 'Original GST', editable: false, visible: true, choices_scope: Choices[:lookup].('tax_rates'), can_editable_be_changed: false, computed: Forms::Compute::Lookup('items.invoice_item_id', '{{record.tax_rate_id}}')
      lookup :tax_rate_id, label: 'Credit Note GST', editable: false, visible: true, choices_scope: Choices[:lookup].('tax_rates'), computed: Forms::Compute::Lookup('items.invoice_item_id', "{% unless row.credit_note_item_type_id == '#{CreditNoteItemType.id_for(:gst_change)}' %}{{ items.original_tax_rate_id }}{% else %}{{record.tax_rate_id}}{% endunless %}")
      number :original_tax_percentage, label: 'Original Tax Percentage', editable: false, visible: true, computed: Forms::Compute::Lookup('items.original_tax_rate_id', '{{record.rate}}'), can_editable_be_changed: false
      amount :original_item_tax_amount, label: 'Original Tax Amount', editable: false, visible: false,
             can_editable_be_changed: false, can_visible_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:original_item_tax_amount]), can_editable_be_changed: false
      number :revised_tax_percentage, label: 'Credit Note Tax Percentage', editable: false, visible: true, computed: Forms::Compute::Lookup('items.tax_rate_id', '{{record.rate}}')
      amount :item_tax_amount, label: 'Credit Note Tax Amount', editable: false, visible: true,
             can_editable_be_changed: false, can_visible_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:item_tax_amount])
      amount :item_total_amount, label: 'Total Amount', editable: false, required: false, visible: true, computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:total_amount])
    end
  end

  section :summary do
    summary :items_summary do
      amount :cn_gross_receivable_amount, label: 'Gross Receivable Amount', editable: false, visible: true, required: true, computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:cn_gross_receivable_amount])
      amount :reporting_cn_gross_receivable_amount, label: 'Reporting Gross Receivable Amount', editable: false, visible: true, required: true, computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_cn_gross_receivable_amount])
      amount :cn_tax_amount, label: 'Tax Amount', editable: false, visible: true, computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:cn_tax_amount])
      amount :reporting_cn_tax_amount, label: ' Reporting Gross Receivable Amount', editable: false, visible: true, required: true, computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_cn_tax_amount])
      lookup :tds_rate_id, choices_scope: Choices[:lookup].('tds_slabs'), visible: true, editable: false
      number :cn_tds_rate, label: 'TDS percentage', editable: false, visible: false, computed: Forms::Compute::Lookup('items_summary.tds_rate_id', '{{record.tds}}')
      amount :cn_tds_amount, label: 'Tds Amount', editable: false, visible: true,
             can_editable_be_changed: false, computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:cn_tds_amount])
      amount :cn_roundoff_amount, label: 'Round off', editable: false, visible: true, computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:cn_roundoff_amount])
      amount :cn_net_receivable_amount, label: 'Net Receivable Amount', editable: false, visible: true, computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:cn_net_receivable_amount])
      amount :reporting_cn_net_receivable_amount, label: ' Reporting Gross Receivable Amount', editable: false, visible: true, required: true, computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_cn_net_receivable_amount])
      amount :cn_previously_adjusted_amount, label: 'Previously Adjusted Amount', editable: false, visible: true, computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:cn_previously_adjusted_amount])
      amount :cn_net_adjustable_amount, label: 'Net Adjustable Amount', editable: false, visible: true, computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:net_adjusted_amount])
      amount :reporting_net_adjusted_amount, label: 'Reporting Gross Receivable Amount', editable: false, visible: true, required: true, computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_net_adjusted_amount])
    end
  end

  section :attachments, associate_custom_fields: true do
    attachment :attachments, system_field: false, required: true
  end

  validation validation_id: 'Credit Note quantity Cannot be more than Original quantity' do
    reference 'items.quantity'
    error_message 'Credit Note Quantity Cannot be more than Original quantity'
    rule Rules::Builder['row.original_quantity'].lt(entity: 'row.quantity')
  end

  validation validation_id: 'Revised rate Cannot be more than Original rate' do
    reference 'items.rate'
    error_message 'Revised rate Cannot be more than Original rate'
    rule Rules::Builder['row.original_rate'].lt(entity: 'row.rate')
  end

  validation validation_id: 'Revised tax Cannot be more than Original tax' do
    reference 'items.tax_rate_id'
    error_message 'Revised tax percentage Cannot be more than Original tax percentage'
    rule Rules::Builder['row.original_tax_percentage'].lt(entity: 'row.revised_tax_percentage')
  end

  # validation validation_id: "CN qty Cannot be more than 0 if credit note type is not quantity changee" do
  #   reference 'items.quantity'
  #   error_message 'Credit Note quantity Cannot be more than 0 if Credit Note type is Quantity change'
  #   rule Rules::Builder['row.original_quantity'].not_eq(entity: 'row.quantity').and(Rules::Builder['row.credit_note_item_type_id'].not_eq(value: CreditNoteItemType.id_for(:qty_change)))
  # end

  validation validation_id: 'cn quantity cannot be negative' do
    reference 'items.quantity'
    error_message 'Credit Note Quantity Cannot be negative'
    rule Rules::Builder['row.quantity'].lt(value: 0)
  end

  validation validation_id: 'cn rate cannot be negative' do
    reference 'items.rate'
    error_message 'Credit Note Quantity Cannot be negative'
    rule Rules::Builder['row.rate'].lt(value: 0)
  end

  # validation validation_id: 'Revised rate Cannot be different than Original rate' do
  #   reference 'items.rate'
  #   error_message 'Revised rate cannot be different than original rate if credit note type is not price drop'
  #   rule Rules::Builder['row.original_rate'].not_eq(entity: 'row.rate').and(Rules::Builder['row.credit_note_item_type_id'].not_eq(value: CreditNoteItemType.id_for(:price_drop)))
  # end

  # validation validation_id: 'Revised tax Cannot be different than Original tax' do
  #   reference 'items.tax_rate_id'
  #   error_message 'Revised tax cannot be different than original tax if credit note type is not Tax change'
  #   rule Rules::Builder['row.original_tax_rate_id'].not_eq(entity: 'row.tax_rate_id').and(Rules::Builder['row.credit_note_item_type_id'].not_eq(value: CreditNoteItemType.id_for(:gst_change)))
  # end

  condition condition_id: 'Items -> Make CN quantity editable if CN type is quantity change' do
    reference :entity, 'items.quantity'
    rule Rules::Builder['row.credit_note_item_type_id'].eq(value: CreditNoteItemType.id_for(:qty_change).to_s)
    action :editable, true
  end

  condition condition_id: 'Items -> Make revised rate editable if CN type is price drop' do
    reference :entity, 'items.rate'
    rule Rules::Builder['row.credit_note_item_type_id'].eq(value: CreditNoteItemType.id_for(:price_drop).to_s)
    action :editable, true
  end

  condition condition_id: 'Items -> Make revised tax rate editable if CN type is gst change' do
    reference :entity, 'items.tax_rate_id'
    rule Rules::Builder['row.credit_note_item_type_id'].eq(value: CreditNoteItemType.id_for(:gst_change).to_s)
    action :editable, true
  end

  condition condition_id: 'Credit note type should not be editable once unless in editable status' do
    reference :entity, 'items.credit_note_item_type_id'
    rule Rules::Builder[:status_id].eq_any(*CreditNoteStatus.ids_for(:draft, :retracted, :awaiting_approval, :rejected).map { |item| { value: item } })
    action :editable, true
    action :required, true
  end

  condition condition_id: 'Comment should not be editable once unless in editable status' do
    reference :entity, 'items.comment'
    rule Rules::Builder[:status_id].eq_any(*CreditNoteStatus.ids_for(:draft, :retracted, :awaiting_approval, :rejected).map { |item| { value: item } })
    action :editable, true
    action :required, true
  end

  # condition condition_id: "conversion rate should not be editable once unless in editable status" do
  #   reference :entity, :conversion_rate
  #   rule Rules::Builder[:status_id].eq_any(*CreditNoteStatus.ids_for(:draft, :retracted, :awaiting_approval, :rejected).map { |item| { value: item } })
  #   action :editable, true
  # end

  condition condition_id: 'Hide Reporting Gross Receivable Amount for Indian currency' do
    reference :entity, 'items_summary.reporting_cn_gross_receivable_amount'
    rule Rules::Builder[:base_currency_id].eq(entity: 'reporting_currency_id')
    action :visible, false
  end

  condition condition_id: 'Hide Reporting Tax Amount for Indian currency' do
    reference :entity, 'items_summary.reporting_cn_tax_amount'
    rule Rules::Builder[:base_currency_id].eq(entity: 'reporting_currency_id')
    action :visible, false
  end

  condition condition_id: 'Hide Reporting Net Receivable for Indian currency' do
    reference :entity, 'items_summary.reporting_cn_net_receivable_amount'
    rule Rules::Builder[:base_currency_id].eq(entity: 'reporting_currency_id')
    action :visible, false
  end

  condition condition_id: 'Hide Reporting Net Adjustable Amount for Indian currency' do
    reference :entity, 'items_summary.reporting_net_adjusted_amount'
    rule Rules::Builder[:base_currency_id].eq(entity: 'reporting_currency_id')
    action :visible, false
  end

  condition condition_id: 'Hide Roundoff for different currency' do
    reference :entity, 'items_summary.cn_roundoff_amount'
    rule Rules::Builder[:base_currency_id].not_eq(entity: 'reporting_currency_id').and(Rules::Builder[:base_currency_id].not_eq(value: Currency.id_for('INR')))
    action :visible, false
  end

  condition condition_id: 'Hide Conversion Rate for Indian currency' do
    reference :entity, 'conversion_rate'
    rule Rules::Builder[:base_currency_id].eq(entity: 'reporting_currency_id')
    action :visible, false
  end

  # condition condition_id: 'Base Currency non editable for Indian vendor' do
  #   reference :entity, 'base_currency_id'
  #   rule Rules::Builder[:vendor_country_id_value].not_eq(value: 'India')
  #   action :editable, true
  # end

  condition condition_id: 'Disable Vendor Pan > No Pan for International Vendors' do
    reference :entity, 'vendor_pan'
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

  condition condition_id: 'Disable Vendor Location > No Location for International Vendors' do
    reference :entity, 'gstin_location_id'
    rule Rules::Builder[:vendor_country_id_value].not_eq(value: 'India')
    action :visible, false
    action :required, false
  end
end
