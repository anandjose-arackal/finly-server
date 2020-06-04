class Forms::TestForm < Forms::API

  model User
  section :header do
    text :first_name
    text :last_name, editable: false, required: false
    data_map :profile, populate_if_empty: UserProfile do
      number :id, visible: false, editable: false, internal: true, can_visible_be_changed: false, can_editable_be_changed: false
      text :employee_id
      text :pan
      number :state
      number :city
      number :gender, computed: Forms::Compute::Form("{{form.first_name}} : {{row.state | times: row.city}}"), editable: false
    end
  end

  condition condition_id: :last_name_editable do
    reference :entity, :last_name
    rule Rules::Builder[:first_name].cont(value: 'Han')
    action :editable, true
  end

  condition condition_id: :last_name_required do
    reference :entity, :last_name
    rule Rules::Builder[:first_name].cont(value: 'Han')
    action :required, true
  end
  condition condition_id: :pan_required do
    reference :entity, 'profile.pan'
    rule Rules::Builder[:first_name].cont(value: 'Han').or(Rules::Builder[:last_name].eq(value: "Solo"))
    action :required, true
  end

  validation validation_id: :first_name_value do
    reference :first_name
    rule Rules::Builder[:first_name].eq(value: "Hann")
    error_message "is a bad name"
  end

  validation validation_id: :pan_value do
    reference 'profile.pan'
    rule Rules::Builder['row.pan'].eq(value: "123")
    error_message "is not legal"
  end

end