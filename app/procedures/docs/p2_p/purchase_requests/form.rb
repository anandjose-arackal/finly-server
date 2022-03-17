class Docs::P2P::PurchaseRequests::Form < Forms::API

  model PurchaseRequest

  meta ->(record) {
    {
      created_by: {
        id: "{{record.creator.id}}",
        name: "{{record.creator.name}}",
        email: "{{record.creator.email}}"
      }
    }
  }

  # # LIQUID FORMULAE
  LIQUID_FORMULAE = {
    items: {
      item_gross_amount: "{{ row.rate | times: row.quantity | default: 0 | round: 2  }}"
      # reporting_item_gross_amount: "{{ row.item_gross_amount | times: form.conversion_rate | default: 0 | round: 2}}"
    },

    # INVOICE SUMMARY
    summary: {
      pr_gross_amount: "{% assign gross_amount = 0 %}{% for item in form.items %}{% if item._destroy == true %}{% continue %}{% else %}{% assign gross_amount = gross_amount | plus: item.item_gross_amount %}{% endif %}{% endfor %}{{ gross_amount | default: 0 | round: 2 }}"
      # reporting_pr_gross_amount: "{{ form.pr_gross_amount | times: form.conversion_rate | default: 0 | round: 2}}",
    }
  }

  # PURCHASE REQUEST STATUS
  section :status do
    lookup :purchase_request_status_id,
           choices_scope: Choices[:lookup].('purchase_request_statuses'),
           required: false, editable: false,
           default_value: PurchaseRequestStatus.id_for(:draft),
           can_editable_be_changed: false
  end

  # REQUEST DETAILS
  section :request_details, title: "Request Details", associate_custom_fields: true do
    auto_number :order_number, label: "Request ID", editable: false, sequence: { prefix: "PR", start_at: '00001' }
    large_text :description, label: "Description", visible: true, required: true
    lookup :policy_id, choices_scope: Choices[:lookup].('policies', permissions: [:purchase_request_initiator]), required: true, editable: true, visible: true
    lookup :location_id, label: 'Location', choices_scope: Choices[:lookup].('locations', assignments: { form: true }), required: true
    switch :cost_allocation_items, label: 'Cost Allocation (Item Level)', required: true, default_value: false
    lookup :department_id, label: "Department", editable: true, visible: true, required: true, choices_scope: Choices[:lookup].('departments', assignments: { form: true })
    
    lookup :cost_center_id, label: "Cost Center", editable: true, visible: true, required: true, choices_scope: Choices[:lookup].('cost_centers')
    large_text :note, label: "Note", visible: true
    date :created_at , label: "Created Date", visible: true, editable: false, computed: Forms::Compute::Form('{{ form.created_at | default: "now" | date: "%Y-%m-%d" }}')
  end
    
  # section :creator_details, title: "Creator Details", associate_custom_fields: true do
  #   lookup :creator_id, label: "Name", required: true, visible: false, editable: false, virtual: true
  #   lookup :creator_email, label: "Email", required: true, visible: true, editable: false, virtual: true, computed: Forms::Compute::Lookup('creator_id', '{{record.email}}')
  # end

  # section :conversion_details, title: "Conversion Details", associate_custom_fields: true do
  #   date :conversion_date, label: "Conversion Date", editable: false, visible: true, computed: Forms::Compute::Form('{{form.created_at}}')
  #   text :reporting_currency_id, label: "Reporting Currency", editable: false, visible: true, can_editable_be_changed: false
  #   lookup :base_currency_id, label: "Base Currency", choices_scope: Choices[:lookup].('form_currencies'), visible: true, editable: true
  #   number :conversion_rate, editable: true, format: 'decimal', default_value: 1, computed: Forms::Compute::Lookup('base_currency_id', '{{ record.currency_conversion_rate }}'), visible: true
  # end

  # PURCHASE REQUEST ITEMS
  section :items, associate_custom_fields: true do
    table :items, min_items: 1, populate_if_empty: PurchaseRequestItem do
  
      number :id, visible: false, editable: false, internal: true, can_visible_be_changed: false, can_editable_be_changed: false

      lookup :item_id, label: "Item", can_visible_be_changed: false, can_editable_be_changed: false, choices_scope: Choices[:lookup].('items'), required: true, editable: true, visible: true
      text :item_description, editable: false, can_editable_be_changed: false, can_visible_be_changed: false, visible: false, computed: Forms::Compute::Lookup('items.item_id', '{{record.description}}')
      text :item_number, label: "Item Code", editable: false, computed: Forms::Compute::Lookup('items.item_id', '{{record.item_number}}')

      text :po_creator, label: "PO Creator", editable: false, can_visible_be_changed: false, can_editable_be_changed: false
      link :po_number, label: "PO Number", editable: false, can_visible_be_changed: false, can_editable_be_changed: false
      
      lookup :vendor_id, label: "Preferred Vendor", can_visible_be_changed: false, can_editable_be_changed: false, choices_scope: Choices[:lookup].('vendors'), editable: true, visible: true
      lookup :items_department_id, label: "Department", editable: false, visible: false, required: false, choices_scope: Choices[:lookup].('departments', assignments: { form: true })
      lookup :items_cost_center_id, label: "Cost Center", editable: false, visible: false, required: false, choices_scope: Choices[:lookup].('cost_centers')

      date :required_by_date, label: "Required by Date", required: true, editable: true, visible: true, restriction: 'not_in_the_past'
      lookup :delivery_location_id, label: 'Location', choices_scope: Choices[:lookup].('locations', assignments: { form: true }), required: true
      lookup :category_id, label: "Category", required: true, visible: true, editable: true, choices_scope: Choices[:lookup].('categories'), computed: Forms::Compute::Lookup('items.item_id', '{{record.category_id}}')
      text :purpose, label: "Purpose / Narration", required: true
      text :hsn_sac, label: "HSN/SAC", editable: true, visible: true, computed: Forms::Compute::Lookup('items.item_id', '{{record.hsn_sac}}')

      number :quantity, label: "Quantity", editable: true, visible: true, required: true, min_value: 1, default_value: 1 # todo - condition
      
      dropdown :unit_of_measurement, label: "Unit of Measurement", choices_scope: Choices[:list].(*Unit.all.map { |v| { id: v.value, name: v.name } }), required: true, editable: true, visible: true, computed: Forms::Compute::Lookup('items.item_id', '{{record.unit_of_measurement}}')

      # amount :item_rate, label: "Item Rate", computed: Forms::Compute::Lookup('items.item_id', '{{ record.rate | default: 0 | round: 2 }}'), visible: true
      amount :rate, label: "Estimated Unit Price", can_editable_be_changed: false, can_visible_be_changed: false, required: true, visible: true, editable: true, computed: Forms::Compute::Lookup('items.item_id', '{{record.rate}}')

      # gross_amount = rate x quantity
      amount :item_gross_amount, label: 'Estimated Total', editable: false, visible: true,
             can_visible_be_changed: false, can_editable_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:item_gross_amount])

      # amount :reporting_item_gross_amount, label: 'Estimated Total(Reporting Currency)', editable: false, visible: false,
      #        can_visible_be_changed: false, can_editable_be_changed: false,
      #        computed: Forms::Compute::Form(LIQUID_FORMULAE[:items][:reporting_item_gross_amount])

      # attachment :attachment, system_field: false

      lookup :status_id, choices_scope: Choices[:enum].(PurchaseRequestItemStatus), required: false, editable: false,
             default_value: PurchaseRequestItemStatus.id_for(:draft), can_editable_be_changed: false

      lookup :reject_item, label: ' ', visible: false, editable: false, choices_scope: Choices[:list].({ id: 1, name: 'Accept' }, { id: 2, name: 'Reject' })

    end
  end

  section :summary do
    summary :items_summary do
      amount :pr_gross_amount, label: 'Total Amount', editable: false, visible: true,
             can_editable_be_changed: false, can_visible_be_changed: false,
             computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:pr_gross_amount])

      # amount :reporting_pr_gross_amount, label: 'Gross Amount(Reporting Currency)', editable: false, visible: false,
      #        can_visible_be_changed: false, can_editable_be_changed: false,
      #        computed: Forms::Compute::Form(LIQUID_FORMULAE[:summary][:reporting_pr_gross_amount])
    end
  end

  # ATTACHMENTS
  section :attachments, associate_custom_fields: true do
    attachment :purchase_request_attachments, system_field: false
  end

  # If reporting currency & base currency are same, then hide conversion_rate

  # VALIDATIONS
  # validation validation_id: "Invoice Date Cannot be Later than Due Date" do
  #   reference 'due_date'
  #   error_message "Invoice Due Date must be After Invoice Date"
  #   rule Rules::Builder['due_date'].lt(entity: "date")
  # end

  # validation validation_id: "Conversion Rate must be greater than 0" do
  #   reference 'conversion_rate'
  #   error_message "Conversion Rate must be greater than 0"
  #   rule Rules::Builder['conversion_rate'].gteq(value: 0.0)
  # end

  # CONDITIONS
  
  condition condition_id: "Policy should not be editable once unless in editable status" do
    reference :entity, :policy_id
    rule Rules::Builder[:purchase_request_status_id].eq_any(*PurchaseRequestStatus.where.not(name: ['draft', 'retracted', 'rejected']).ids.map { |item| { value: item } })
    action :editable, false
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

  condition condition_id: "Enable item PO creator > Item PO Creator should be visible for po created" do
    reference :entity, 'items.po_creator'
    rule Rules::Builder[:purchase_request_status_id].eq_any(*PurchaseRequestStatus.where(name: ['draft', 'retracted', 'rejected', 'awaiting_approval']).ids.map { |item| { value: item } })
    action :visible, false
  end

  condition condition_id: "Enable item PO creator > Item PO Number should be visible for po created" do
    reference :entity, 'items.po_number'
    rule Rules::Builder[:purchase_request_status_id].eq_any(*PurchaseRequestStatus.where(name: ['draft', 'retracted', 'rejected', 'awaiting_approval']).ids.map { |item| { value: item } })
    action :visible, false
  end

  condition condition_id: "Enable item rejected_status > Item Rejected Status should be visible for awaiting approval" do
    reference :entity, 'items.reject_item'
    rule Rules::Builder[:purchase_request_status_id].eq_any(*PurchaseRequestStatus.where(name: ['awaiting_approval']).ids.map { |item| { value: item } })
    action :visible, true
    action :required, true
    action :editable, true
  end

end