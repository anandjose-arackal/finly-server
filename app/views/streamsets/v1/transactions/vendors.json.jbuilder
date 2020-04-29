# This is a replica of the vendor master index api
# 

json.result do

  json.array!(@result.paginated_vendors) do |vendor|
    json.rejection_note vendor.reject_note
    json.trade_name vendor.trade_name
    json.pan vendor.pan
    json.gstin vendor.gstin_locations&.pluck(:gstin)
    json.extract! vendor, :id, :name, :business_name, :description, :vendor_id, :email, :mobile_number, :msme_registration_number, :msme_registered
    json.vendor_id vendor&.vendor_id
    json.vendor_type vendor.vendor_type&.as_json
    json.vendor_disabled vendor.deactivated?

    json.status vendor.status.as_json

    json.description vendor.description
    json.created_by vendor.created_by&.name
    json.created_at vendor.created_at.strftime "%d %b %y"
    json.updated_at vendor.updated_at.strftime "%d %b %y"
    json.vendor_creator vendor.created_by&.json_for_trail({:streamsets => true})

    json.tds_rates vendor.tds_rates&.as_json
    json.tds_available vendor.tds_rates.present?

    json.bank_accounts do
      json.array!(vendor.bank_accounts.map {|ba| ba if ba.deleted_at == nil}.compact) do |bank_account|
        json.extract! bank_account, :id, :ifsc, :name, :account_number
        json.default bank_account.default_account
      end
    end

    json.gstin_locations do
      json.array!(vendor.gstin_locations) do |gstin_location|
        json.extract! gstin_location, :id, :gstin, :poc_name, :poc_mobile_number, :poc_email, :poc_fax, :poc_designation, :state_id, :location, :address
        json.card_id gstin_location.id
        if gstin_location.gstin_master.present?
          json.result do
            json.extract! gstin_location.gstin_master, :id, :gstin, :legal_name_of_business, :state, :date_of_registration,
                          :constitution_of_business, :taxpayer_type, :status, :api_response, :address
          end
        end
        gstin_master = Gstin.with_gstin(gstin_location.gstin).first
        if gstin_master.present?
          json.verified_details do
            json.address gstin_master&.address
            json.constitution_of_business gstin_master&.constitution_of_business
            json.date_of_registration gstin_master&.date_of_registration
            json.gstin gstin_master&.gstin
            json.legal_name_of_business gstin_master&.legal_name_of_business
            json.match_percentile StringUtils.fuzzy_string_match(StringUtils.clear_generic_keywords(vendor.business_name), StringUtils.clear_generic_keywords(gstin_master&.legal_name_of_business))
            json.state gstin_master&.state
            json.status gstin_master&.status
            json.trade_name gstin_master&.trade_name
          end
        end
      end
    end

    custom_fields = vendor.custom_fields.map {|cf| {name: cf&.field_configuration&.field_name, value: cf&.string_value}}
    json.custom_fields custom_fields

    custom_fields.each do |custom_field|
      json.set! custom_field[:name], custom_field[:value]
    end

  end
end

json.count @result.vendors.count