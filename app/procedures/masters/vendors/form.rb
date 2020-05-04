class Masters::Vendors::Form < Forms::API

  section :header do
    auto_number :vendor_id, sequence: {prefix: "VNDR/", start_at: '000001'}
    dropdown :status_id, choices_provider: Choices[:enum].(VendorStatus),
             required: true, editable: false, default_value: VendorStatus.id_for(:draft),
             can_editable_be_changed: false
    lookup :policy_id,
           choices_provider: Choices[:lookup].('policies',
               permissions: [:vendor_creator, :vendor_manager]),
           required: true
    text :legal_name
  end

  collection :locations, populate_if_empty: GstinLocation, min_items: 1 do
    location :name, required: true
    dropdown :state_id, required: true,
             choices_provider: Choices[:enum].(GstStateCode,name: :name)
  end

  condition :editable do
    entity :policy_id
    rule :status_id, 'in', VendorStatus.ids_for(:draft, :rejected, :retracted)
  end

  # validation :name do
  #   rule :name, 'not_cont', 'Hello'
  # end

  # validate :locations, min_items: 1

end