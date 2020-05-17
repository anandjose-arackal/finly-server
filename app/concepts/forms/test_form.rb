class Forms::TestForm < Forms::API

  model User
  section :header do
    text :first_name
    text :last_name, editable: false, required: false
    data_map :profile, populate_if_empty: UserProfile do
      text :employee_id
      text :pan
      number :state
      number :city
      number :gender, computed: "{{form.first_name}} : {{row.state | times: row.city}}", editable: false
    end
  end

  condition condition_id: :last_name_editable do
    reference :entity, :last_name
    rule rule_builder[:first_name].cont(value: 'Han')
    action :editable, true
  end

  condition condition_id: :last_name_required do
    reference :entity, :last_name
    rule rule_builder[:first_name].cont(value: 'Han')
    action :required, true
  end
  condition condition_id: :pan_required do
    reference :entity, 'profile/pan'
    rule rule_builder[:first_name].cont(value: 'Han').or(rule_builder[:last_name].eq(value: "Solo"))
    action :required, true
  end

  validation validation_id: :first_name_value do
    entity_path :first_name
    rule rule_builder[:first_name].eq(value: "Hann")
    error_message "is a bad name"
  end

  validation validation_id: :pan_value do
    entity_path 'profile/pan'
    rule rule_builder['row.pan'].eq(value: "123")
    error_message "is not legal"
  end

  # section :header do
  #   auto_number :invoice_id, sequence:{prefix: "TF/{{\"now\" | date: \"%y-%m\" }}/", start_at: "000001"}
  #   text :name, hint: "Please enter the name of the field", maximum: 255
  # end
  #
  # section :line_items do
  #   collection :line_items do
  #     text :item_description, hint: "Please enter the name of the field", maximum: 255
  #     dropdown :status_id, scope: Choicess::List({value: 1, name: 'Approved'}, {value: 1, name: 'Pending'})
  #     dropdown :department_id, scope: Choicess::AutoComplete('departments', filters: {})
  #   end
  # end

end