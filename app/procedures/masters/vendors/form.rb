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

    switch :authorized, default_value: true,
           visible: false, editable: false, required: true,
           can_visible_be_changed: false, can_editable_be_changed: false, can_required_be_changed: false
  end

  section :business_details, associate_custom_fields: true do
    auto_number :vendor_id, label: "Vendor ID", sequence: {prefix: "VNDR.", start_at: '000001'}, placeholder: "System Generated Field", hint: "System Generated Field"
    dropdown :vendor_country, choices_scope: Choices[:list].({id: 'India', name: "India"}, {id: 'International', name: "International"}),
             required: true, default_value: 'India'
    lookup :policy_id,
           choices_scope: Choices[:lookup].('policies', permissions: [:vendor_creator, :vendor_manager]),
           required: true
    # text :name, computed: Forms::Compute::Lookup('policy_id', '{{record.name}}'), editable: false

    text :business_name, label: 'Legal Name', required: true
    text :trade_name, label: 'Trade Name', required: true
    switch :gst_registered, label: "GST Registered"
    large_text :address, label: "Full Address"
    lookup :vendor_type_id, choices_scope: Choices[:lookup].('vendor_types'), label: "Vendor Type"
    lookup :payment_term_id, choices_scope: Choices[:lookup].('payment_terms'), label: "Payment Term"
  end

  section :tax_information, title: "Tax Information & Details", associate_custom_fields: true do
    # PAN
    text :pan, unique: true
    attachment :pan_attachment, system_field: false
    # RCM
    switch :rcm_enabled, label: "RCM Enabled"

    # TDS
    lookup :tds_rates_list_id, choices_scope: Choices[:lookup].('tds_slabs'), label: "TDS Percentage"
    date :tds_effective_start_date, label: "TDS Effective Start Date", editable: false
    date :tds_effective_end_date, label: "TDS Effective End Date", editable: false

    # Sales Tax Codes
    lookup :tax_rate_id, choices_scope: Choices[:lookup].('tax_rates'), label: "Sales Tax Code", visible: false, editable: false
  end

  section :msme, associate_custom_fields: true do
    # MSME
    switch :msme_registered
    text :msme_registration_number, editable: false
    attachment :msme_registration_certificate, system_field: false
  end

  section :ldc, associate_custom_fields: true do
    # LDC
    amount :ldc_upper_limit_amount, label: "LDC Upper Limit"
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
    data_map :gstin_locations, populate_if_empty: GstinLocation, min_items: 1, associate_custom_fields: true do
      text :location
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
      dropdown :gst_status, choices_scope: Choices[:list].({id: 'Active', name: "Active"}, {id: 'Cancelled', name: "Cancelled"}, {id: 'Provisional', name: 'Provisional'}, {id: 'Inactive', name: 'Inactive'}),
               required: false
      switch :verified, visible: false, default_value: false
      large_text :gstin_fetch_details, visible: false
      attachment :gstin_certificate, system_field: false

    end
  end

  section :account_details, associate_custom_fields: true do
    data_map :bank_accounts, populate_if_empty: BankAccount, min_items: 1, associate_custom_fields: true do
      text :name, required: true
      text :account_number, required: true, unique: true, regex: {format: "\\A[A-Za-z0-9]{3,32}\\z", message: "is not in valid format"}
      text :confirm_account_number, required: true, system_field: false
      text :ifsc, label: "IFSC", required: true, regex: {format: "\\A[A-Za-z]{4}[a-zA-Z0-9]{7}\\z", message: "is not valid"}
      text :swift_code, label: "Swift / Bank Code", required: false, visible: false, editable: false, regex: {format: "^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$", message: "is not valid"}
      switch :default_account
      switch :disabled, default_value: false
      switch :verified, visible: false, default_value: false
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

  condition condition_id: "Policy should not be editable once unless in editable status" do
    reference :entity, :policy_id
    rule Rules::Builder[:status_id].eq_any(*VendorStatus.ids_for(:awaiting_approval, :approved, :auto_approved, :deactivated).map {|item| {value: item}})
    action :editable, false
    action :required, false
  end

  condition condition_id: "Disable Locations(GSTIN) for International Vendors" do
    reference :entity, :gstin_locations
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :editable, false
    action :visible, false
    action :required, false
    action :active, false
  end

  condition condition_id: 'Disabled State ID for International Vendor' do
    reference :entity, 'gstin_locations.state_id'
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :editable, false
    action :visible, false
    action :required, false
    action :active, false
  end

  condition condition_id: "Disable GST Registerd for International Vendors" do
    reference :entity, :gst_registered
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :editable, false
    action :visible, false
    action :required, false
  end

  condition condition_id: "Enable Tax Residency Certificate Attachment for International Vendors" do
    reference :entity, :tax_residency_certificate
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :editable, true
    action :visible, true
  end

  condition condition_id: "Enable Form 10F Attachment for International Vendors" do
    reference :entity, :form_10f
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :editable, true
    action :visible, true
  end

  condition condition_id: "Enable No PE Attachment for International Vendors" do
    reference :entity, :no_pe_declaration
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :editable, true
    action :visible, true
  end

  condition condition_id: "Disable PAN for International Vendors" do
    reference :entity, :pan
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :editable, false
    action :visible, false
    action :active, false
    action :required, false
  end

  condition condition_id: "Hide PAN Attachment for International Vendors" do
    reference :entity, :pan_attachment
    rule Rules::Builder[:vendor_country].not_eq(value: "India")
    action :editable, false
    action :visible, false
    action :required, false
  end

  condition condition_id: "Disable RCM Enabled for International Vendors" do
    reference :entity, :rcm_enabled
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :editable, false
    action :visible, false
    action :active, false
    action :required, false
  end

  condition condition_id: "Enable Tax Rates for International Vendors" do
    reference :entity, :tax_rate_id
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :editable, true
    action :visible, true
    action :active, true
  end

  condition condition_id: "Disable TDS Rate for International Vendors" do
    reference :entity, :tds_rates_list_id
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :editable, false
    action :visible, false
    action :active, false
    action :required, false
  end

  condition condition_id: "Make TDS Effective Start Date Editable when TDS Rate value present" do
    reference :entity, :tds_effective_start_date
    rule Rules::Builder[:tds_rates_list_id].present
    action :editable, true
  end

  condition condition_id: "Make TDS Effective End Date Editable when TDS Rate value present" do
    reference :entity, :tds_effective_end_date
    rule Rules::Builder[:tds_rates_list_id].present
    action :editable, true
  end

  condition condition_id: "Disable TDS Effective Start Date for International Vendors" do
    reference :entity, :tds_effective_start_date
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :editable, false
    action :visible, false
    action :active, false
  end

  condition condition_id: "Disable TDS Effective End Date for International Vendors" do
    reference :entity, :tds_effective_end_date
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :editable, false
    action :visible, false
    action :active, false
  end


  # MSME Conditions
  condition condition_id: "Disable MSME Registered for International Vendors" do
    reference :entity, :msme_registered
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :editable, false
    action :visible, false
    action :active, false
    action :required, false
  end


  condition condition_id: "Disable MSME Registration Number for International Vendors" do
    reference :entity, :msme_registration_number
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :editable, false
    action :visible, false
    action :active, false
    action :required, false
  end

  condition condition_id: "Enable MSME Registration Number when MSME Registered is checked" do
    reference :entity, :msme_registration_number
    rule Rules::Builder[:msme_registered].present
    action :editable, true
  end

  condition condition_id: "Disable MSME Attachment for International Vendors" do
    reference :entity, :msme_registration_certificate
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :editable, false
    action :visible, false
    action :required, false
  end

  # LDC Conditions
  condition condition_id: "Disable LDC for International Vendors" do
    reference :entity, :ldc_upper_limit_amount
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :editable, false
    action :visible, false
    action :active, false
    action :required, false
  end
  condition condition_id: "Disable LDC Start Date for International Vendors" do
    reference :entity, :ldc_effective_start_date
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :editable, false
    action :visible, false
    action :active, false
    action :required, false
  end
  condition condition_id: "Disable LDC End Date for International Vendors" do
    reference :entity, :ldc_effective_end_date
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :editable, false
    action :visible, false
    action :active, false
    action :required, false
  end
  condition condition_id: "Make LDC Start Date Non Editable when LDC Upperlimit is Not Provided" do
    reference :entity, :ldc_effective_start_date
    rule Rules::Builder[:ldc_upper_limit_amount].blank
    action :editable, false
  end
  condition condition_id: "Make LDC End Date Non Editable when LDC Upperlimit is Not Provided" do
    reference :entity, :ldc_effective_end_date
    rule Rules::Builder[:ldc_upper_limit_amount].blank
    action :editable, false
  end

  condition condition_id: "Disable Lower Exemption Certificate Attachment for International Vendors" do
    reference :entity, :lower_exception_certificate
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :editable, false
    action :visible, false
    action :required, false
  end

  condition condition_id: "Disable Tax Exemption Certificate for International Vendors" do
    reference :entity, :tax_exemption_certificate
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :editable, false
    action :visible, false
    action :required, false
  end

  condition condition_id: "Disable Locations > GSTIN for International Vendors" do
    reference :entity, 'gstin_locations.gstin'
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :editable, false
    action :visible, false
    action :active, false
    action :required, false
  end

  condition condition_id: "Disable Locations > GST Status for International Vendors" do
    reference :entity, 'gstin_locations.gst_status'
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :editable, false
    action :visible, false
    action :active, false
    action :required, false
  end

  condition condition_id: "Disable Locations > GSTIN Certificate for International Vendors" do
    reference :entity, 'gstin_locations.gstin_certificate'
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :editable, false
    action :visible, false
    action :required, false
  end

  condition condition_id: "Enable Bank Accounts > Swift / BIC Code for International Vendors" do
    reference :entity, 'bank_accounts.swift_code'
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :editable, true
    action :visible, true
    action :required, true
  end

  condition condition_id: "Disable Bank Accounts > IFS Code for International Vendors" do
    reference :entity, 'bank_accounts.ifsc'
    rule Rules::Builder[:vendor_country].not_eq(value: 'India')
    action :editable, false
    action :visible, false
    action :required, false
  end

  validation validation_id: :"confirm bank account" do
    reference 'bank_accounts.confirm_account_number'
    error_message "doesn't match with account number"
    rule Rules::Builder['row.account_number'].not_eq(entity: 'row.confirm_account_number')
  end

  validation validation_id: "PAN should match with GSTIN" do
    reference 'gstin_locations.gstin'
    error_message "doesn't match with PAN"
    # rule Rules::Builder["row.gstin"].present.and(Rules::Builder[:pan].present.and(Rules::Builder["row.gstin"].not_cont_any(entity: :pan)))
    # rule Rules::Builder['row.gstin'].not_cont_any(entity: :pan)
    # rule Rules::Builder[:vendor_country].eq_any({value: "India"}).and(Rules::Builder["row.gstin"].not_cont_any(entity: :pan))
    rule Rules::Builder["form.pan"].present.and(Rules::Builder["row.gstin"].present.and(Rules::Builder["row.gstin"].not_cont_any(entity: :pan)))
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