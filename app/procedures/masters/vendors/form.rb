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

  section :business_details, associate_custom_fields: true do
    auto_number :vendor_id, sequence: {prefix: "VNDR.", start_at: '000001'}
    dropdown :vendor_country, choices_scope: Choices[:list].({id: 'India', name: "India"}, {id: 'International', name: "International"}),
             required: true, default_value: 'India'
    lookup :policy_id,
           choices_scope: Choices[:lookup].('policies', permissions: [:vendor_creator, :vendor_manager]),
           required: true
    # text :name, computed: Forms::Compute::Lookup('policy_id', '{{record.name}}'), editable: false

    text :business_name, label: 'Legal Name', required: true
    text :name, label: 'Trade Name', required: true
    switch :gst_registered, label: "GST Registered"
    large_text :address, label: "Full Address"
    # lookup :vendor_type_id, choices_scope: Choices[:lookup].('vendor_types'), label: "Vendor Type"
    lookup :payment_term_id, choices_scope: Choices[:lookup].('payment_terms'), label: "Payment Term"
  end

  section :tax_information, title: "Tax Information & Details", associate_custom_fields: true do
    # PAN
    text :pan
    attachment :pan_card, system_field: false
    # RCM
    switch :rcm_enabled, label: "RCM Enabled"

    # TDS
    dropdown :tds_rates_list_id, choices_scope: Choices[:lookup].('tds_slabs'), label: "TDS Percentage"
    date :tds_effective_start_date, label: "TDS Effective Start Date"
    date :tds_effective_end_date, label: "TDS Effective End Date"

    # Sales Tax Codes
    lookup :tax_rate_id, choices_scope: Choices[:lookup].('tax_rates'), label: "Sales Tax Code", visible: false, editable: false
  end

  section :msme, associate_custom_fields: true do
    # MSME
    switch :msme_registered
    text :msme_registration_number
    attachment :msme_registration_certificate, system_field: false
  end

  section :ldc, associate_custom_fields: true do
    # LDC
    amount :ldc_upper_limit_id, label: "LDC Upper Limit"
    date :ldc_effective_start_date, label: "LDC Effect Start Date"
    date :ldc_effective_end_date, label: "LDC Effect End Date"
    attachment :lower_exception_certificate, system_field: false
  end

  # section :tds, associate_custom_fields: true do
  #   dropdown :tds_rates_list_id, Choices[:lookup].('tds_slabs')
  #   date :effective_start_date, system_field: false
  #   date :effective_end_date, system_field: false
  # end

  section :location_details, associate_custom_fields: true do
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
      attachment :gstin_certificate, system_field: false
    end
  end

  section :account_details, associate_custom_fields: true do
    data_map :bank_accounts, populate_if_empty: BankAccount, min_items: 1 do
      text :name, required: true
      text :account_number, required: true
      text :confirm_account_number, required: true, system_field: false
      text :ifsc, label: "IFSC / Bank Code", required: true
      switch :default_account
      switch :disabled, default_value: false
      attachment :cancelled_cheque, system_field: false
    end
  end

  section :attachments, associate_custom_fields: true do
    attachment :tax_exemption_certificate, system_field: false
    attachment :other_documents, system_field: false
    attachment :tax_residency_certificate, label: 'Tax Residency Certificate', system_field: false, visible: false, editable: false
    attachment :form_10f, label: 'Form 10 F', system_field: false, visible: false, editable: false
    attachment :no_pe_declaration, label: 'No PE Declaration', system_field: false, visible: false, editable: false

  end

  condition condition_id: :attachment_tax_residency_for_international_vendors do
    reference :entity, :tax_residency_certificate
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :editable, true
    action :visible, true
  end

  condition condition_id: :attachment_form_10f_for_international_vendors do
    reference :entity, :form_10f
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :editable, true
    action :visible, true
  end

  condition condition_id: :attachment_no_pe_for_international_vendors do
    reference :entity, :no_pe_declaration
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :editable, true
    action :visible, true
  end

  condition condition_id: :pan_for_indian_vendors do
    reference :entity, :pan
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :editable, false
    action :visible, false
    action :active, false
    action :required, false
  end

  condition condition_id: :rcm_for_indian_vendors do
    reference :entity, :rcm_enabled
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :editable, false
    action :visible, false
    action :active, false
    action :required, false
  end

  condition condition_id: :tax_rate_international_vendors do
    reference :entity, :tax_rate_id
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :editable, true
    action :visible, true
    action :active, true
  end

  condition condition_id: :tds_for_indian_vendors do
    reference :entity, :tds_rates_list_id
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :editable, false
    action :visible, false
    action :active, false
    action :required, false
  end

  condition condition_id: :tds_start_date_for_indian_vendors do
    reference :entity, :tds_effective_start_date
    rule Rules::Builder[:tds_rates_list_id].blank
    action :editable, false
  end

  condition condition_id: :tds_end_date_for_indian_vendors do
    reference :entity, :tds_effective_end_date
    rule Rules::Builder[:tds_rates_list_id].blank
    action :editable, false
  end


  # MSME Conditions
  condition condition_id: :msme_for_indian_vendors do
    reference :entity, :msme_registered
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :editable, false
    action :visible, false
    action :active, false
    action :required, false
  end
  condition condition_id: :msme_number_when_msme_registered do
    reference :entity, :msme_registration_number
    rule Rules::Builder[:msme_registered].blank
    action :editable, false
  end
  condition condition_id: :msme_number_for_indian_vendors do
    reference :entity, :msme_registration_number
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :editable, false
    action :visible, false
    action :active, false
    action :required, false
  end

  # LDC Conditions
  condition condition_id: :ldc_for_indian_vendors do
    reference :entity, :ldc_upper_limit_id
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :editable, false
    action :visible, false
    action :active, false
    action :required, false
  end
  condition condition_id: :ldc_start_date_indian_vendors do
    reference :entity, :ldc_effective_start_date
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :editable, false
    action :visible, false
    action :active, false
    action :required, false
  end
  condition condition_id: :ldc_end_date_indian_vendors do
    reference :entity, :ldc_effective_end_date
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :editable, false
    action :visible, false
    action :active, false
    action :required, false
  end
  condition condition_id: :ldc_start_date_for_amount do
    reference :entity, :ldc_effective_start_date
    rule Rules::Builder[:ldc_upper_limit_id].blank
    action :editable, false
  end
  condition condition_id: :ldc_end_date_for_amount do
    reference :entity, :ldc_effective_end_date
    rule Rules::Builder[:ldc_upper_limit_id].blank
    action :editable, false
  end


  condition condition_id: :gst_for_indian_vendors do
    reference :entity, :gst_registered
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :editable, false
    action :visible, false
    action :active, false
    action :required, false
  end

  validation validation_id: :"confirm bank account" do
    reference 'bank_accounts.confirm_account_number'
    error_message "doesn't match with account number"
    rule Rules::Builder['bank_accounts.account_number'].not_eq(entity: 'bank_accounts.confirm_account_number')
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