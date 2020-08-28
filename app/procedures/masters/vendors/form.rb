# class Masters::Vendors::Form < Forms::API
#
#   model YesBankVendor
#
#   section :status do
#     dropdown :status_id, choices_scope: Choices[:enum].(VendorStatus),
#              required: false, editable: true, default_value: VendorStatus.id_for(:draft),
#              can_editable_be_changed: false
#   end
#
#   section :business_details do
#     auto_number :vendor_id, sequence: {prefix: "VNDR.", start_at: '000001'}
#     lookup :policy_id,
#            choices_scope: Choices[:lookup].('policies', permissions: [:vendor_creator, :vendor_manager]),
#            required: true
#     # text :name, computed: Forms::Compute::Lookup('policy_id', '{{record.name}}'), editable: false
#
#     text :business_name, label: 'Legal Name', required: true
#     text :name, label: 'Trade Name'
#     large_text :address
#   end
#
#   validation validation_id: :name_cont_validation do
#     reference :name
#     error_message "Stop Bullshitting me"
#     rule Rules::Builder['name'].not_cont(value: "XXX")
#   end
#
#   condition condition_id: :test_address_condition do
#     reference :entity, :address
#     rule Rules::Builder[:name].blank
#     action :editable, false
#   end

# section :attachments do
#   attachment :pan_card, system_field: false
#   attachment :gstin_certificate, system_field: false
#   attachment :cancelled_cheque, system_field: false
#   attachment :tax_exemption_certificate, system_field: false
#   attachment :lower_exception_certificate, system_field: false
#   attachment :msme_registration_certificate, system_field: false
#   attachment :other_documents, system_field: false
# end



# condition condition_id: :department_id_editable do
#   reference :entity, :department_id
#   rule Rules::Builder[:policy_id].eq(value: 4)
#   action :editable, true
# end
#
# condition condition_id: :policy_id_status_editable do
#   reference :entity, :policy_id
#   rule Rules::Builder[:status_id].in(value: VendorStatus.ids_for(:draft, :rejected, :retracted))
#   action :editable, true
# end
#
# condition condition_id: :name_status_editable do
#   reference :entity, 'locations.name'
#   rule Rules::Builder[:status_id].in(value: VendorStatus.ids_for(:draft, :rejected, :retracted))
#   action :editable, true
# end
#
# condition condition_id: :status_location_name_mandatory do
#   reference :entity, 'locations.name'
#   rule Rules::Builder[:status_id].in(value: VendorStatus.ids_for(:draft, :rejected, :retracted)).and(
#       Rules::Builder[:age].not_eq(value: 20)
#   )
#   action :required, false
# end
#
# validation validation_id: :name_cont_validation do
#   reference 'locations.name'
#   error_message "Name cannot contain Hello"
#   rule Rules::Builder['locations.name'].not_cont(value: "Hello")
# end
#
# choice_dependency dependency_id: :policy_dependency do
#   reference controller: :policy_id, dependent: :department_id
#   dependency "Company (Default)", ["test1"]
# end

# end


class Masters::Vendors::Form < Forms::API

  model YesBankVendor

  section :status do
    dropdown :status_id, choices_scope: Choices[:enum].(VendorStatus),
             required: false, editable: true, default_value: VendorStatus.id_for(:draft),
             can_editable_be_changed: false
  end

  section :business_details do
    auto_number :vendor_id, sequence: {prefix: "VNDR.", start_at: '000001'}
    lookup :policy_id,
           choices_scope: Choices[:lookup].('policies', permissions: [:vendor_creator, :vendor_manager]),
           required: true
    # text :name, computed: Forms::Compute::Lookup('policy_id', '{{record.name}}'), editable: false

    text :business_name, label: 'Legal Name', required: true
    text :name, label: 'Trade Name'
    text :pan
    switch :gst_registered
    large_text :address
    dropdown :vendor_type, Choices[:lookup].('vendor_types')
  end

  section :tax_information do
    switch :msme_registered
    text :msme_registration_number # dropdown :tds_rates_list_id, choices_scope: Choices[:lookup].('')
  end

  section :tds do
    dropdown :tds_rates_list_id, Choices[:lookup].('tds_slabs')
    date :effective_start_date, system_field: false
    date :effective_end_date, system_field: false
  end

  section :location_details do
    data_map :gstin_locations, populate_if_empty: GstinLocation, min_items: 1 do
      dropdown :state_id, required: true,
               choices_scope: Choices[:enum].(GstStateCode, name: :name)
      text :poc_name, label: "Point of Contact"
      text :poc_mobile_number
      text :poc_email
      text :poc_fax
      text :poc_designation
      large_text :address
      lookup :gstin_id, visible: false
      text :gstin
    end
  end

  section :account_details do
    data_map :bank_accounts, populate_if_empty: BankAccount, min_items: 1 do
      text :name, required: true
      text :account_number, required: true
      text :ifsc, required: true
      switch :default_account
      switch :disabled
    end
  end

  section :attachments do
    attachment :pan_card, system_field: false
    attachment :gstin_certificate, system_field: false
    attachment :cancelled_cheque, system_field: false
    attachment :tax_exemption_certificate, system_field: false
    attachment :lower_exception_certificate, system_field: false
    attachment :msme_registration_certificate, system_field: false
    attachment :other_documents, system_field: false
  end


  # condition condition_id: :department_id_editable do
  #   reference :entity, :department_id
  #   rule Rules::Builder[:policy_id].eq(value: 4)
  #   action :editable, true
  # end
  #
  # condition condition_id: :policy_id_status_editable do
  #   reference :entity, :policy_id
  #   rule Rules::Builder[:status_id].in(value: VendorStatus.ids_for(:draft, :rejected, :retracted))
  #   action :editable, true
  # end
  #
  # condition condition_id: :name_status_editable do
  #   reference :entity, 'locations.name'
  #   rule Rules::Builder[:status_id].in(value: VendorStatus.ids_for(:draft, :rejected, :retracted))
  #   action :editable, true
  # end
  #
  # condition condition_id: :status_location_name_mandatory do
  #   reference :entity, 'locations.name'
  #   rule Rules::Builder[:status_id].in(value: VendorStatus.ids_for(:draft, :rejected, :retracted)).and(
  #       Rules::Builder[:age].not_eq(value: 20)
  #   )
  #   action :required, false
  # end
  #
  # validation validation_id: :name_cont_validation do
  #   reference 'locations.name'
  #   error_message "Name cannot contain Hello"
  #   rule Rules::Builder['locations.name'].not_cont(value: "Hello")
  # end
  #
  # choice_dependency dependency_id: :policy_dependency do
  #   reference controller: :policy_id, dependent: :department_id
  #   dependency "Company (Default)", ["test1"]
  # end

end