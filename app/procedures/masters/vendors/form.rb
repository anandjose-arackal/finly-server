class Masters::Vendors::Form < Forms::API

  model YesBankVendor

  section :header do
    auto_number :vendor_id, sequence: {prefix: "VNDR/", start_at: '000001'}
    dropdown :status_id, choices_scope: Choices[:enum].(VendorStatus),
             required: true, editable: false, default_value: VendorStatus.id_for(:draft),
             can_editable_be_changed: false
    lookup :policy_id,
           choices_scope: Choices[:lookup].('policies',
               permissions: [:vendor_creator, :vendor_manager]),
           required: true
    lookup :department_id, choices_scope: Choices[:lookup].('departments'), editable: false, visible: false
    lookup :cost_center_id, choices_scope: Choices[:lookup].('cost_centers')
    text :legal_name
  end

  section :locations do
    data_map :locations, populate_if_empty: GstinLocation, min_items: 1 do
      text :name, required: true
      dropdown :state_id, required: true,
               choices_scope: Choices[:enum].(GstStateCode, name: :name)
    end
  end

  # condition condition_id: :department_id_editable do
  #   reference :entity, :department_id
  #   rule :policy_id, 'eq', value: 4
  #   action :editable, true
  # end
  #
  # condition condition_id: :policy_id_status_editable do
  #   reference :entity, :policy_id
  #   rule :status_id, 'in', value: VendorStatus.ids_for(:draft, :rejected, :retracted)
  #   action :editable, true
  # end
  #
  # condition condition_id: :name_status_editable do
  #   reference :entity, :name
  #   rule :status_id, 'in', value: VendorStatus.ids_for(:draft, :rejected, :retracted)
  #   action :editable, true
  # end
  #
  # condition condition_id: :status_location_name_mandatory do
  #   reference :entity, 'locations/name'
  #   rule :status_id, 'in', value: VendorStatus.ids_for(:draft, :rejected, :retracted)
  #   rule :age, 'in', value: VendorStatus.ids_for(:draft, :rejected, :retracted)
  #   action :required, false
  # end
  #
  # validation entity_path: :name, validation_id: :name_cont_validation do
  #   error_message "Name cannot contain Hello"
  #   rule 'locations/name', 'not_cont', value: 'Hello'
  # end

  # choice_dependency dependency_id: :policy_dependency do
  #   reference controller: :policy_id, dependent: :department_id
  #   dependency "Company (Default)", ["test1"]
  # end

end