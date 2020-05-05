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
    text :legal_name
  end

  section :locations do
    data_map :locations, populate_if_empty: GstinLocation, min_items: 1 do
      text :name, required: true
      dropdown :state_id, required: true,
               choices_scope: Choices[:enum].(GstStateCode, name: :name)
    end
  end

  condition entity_path: :policy_id, id: :policy_id_status_editable do
    rule :status_id, 'in', value: VendorStatus.ids_for(:draft, :rejected, :retracted)
    action :editable, true
  end

  condition entity_path: 'locations/name', id: :status_location_name_mandatory do
    rule :status_id, 'in', value: VendorStatus.ids_for(:draft, :rejected, :retracted)
    action :required, false
  end

  validation entity_path: :name, id: :name_cont_validation do
    rule :name, 'not_cont', value: 'Hello'
  end

end