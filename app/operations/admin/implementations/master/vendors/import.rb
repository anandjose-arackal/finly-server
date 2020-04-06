class Admin::Implementations::Master::Vendors::Import < Admin::Implementations::Processor::Import

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'vendors.import'
  headers ({
      :id => "ID",
      :business_name => "Legal Name",
      :vendor_type => "Vendor Type",
      :vendor_id => "Vendor Code",
      :trade_name => "Trade Name",
      :mobile_number => "Mobile Number",
      :email => "Email",
      :pan => "PAN",
      :description => "Description",
      :address => "Address",
      :gstin => "GSTIN",
      :gst_location => "GST Location",
      :state => "GST State",
      :vendor_bank_account_name => "Bank Account Name",
      :account_number => "Account Number",
      :ifsc => "IFSC",
      :destroy => "Destroy"
  })

  attr_accessor :vendor_params

  def create_record(data)
    vendor_params, messages = set_params(data)
    unless messages.blank?
      return result false, messages.join(', ')
    end
    #support for multiple gstin locations in import
    vendor = check_existing_vendor(vendor_params["vendor"])
    if vendor && vendor_params["vendor"]["gstin_locations_attributes"]
      if check_existing_location(vendor, vendor_params["vendor"]["gstin_locations_attributes"].first)
        vendor.gstin_locations.build(vendor_params["vendor"]["gstin_locations_attributes"])
        unless vendor.save
          return result false, vendor.errors.full_messages
        end
        return result true, 'Created Successfully'
      else
        return result false, 'Existing Vendor and Existing Gstin Location'
      end
    end

    vendor = self.company.yes_bank_vendors.build(vendor_params["vendor"])
    unless vendor.validate
      return result false, vendor.errors.full_messages
    end

    unless vendor.save
      return result false, vendor.errors.full_messages
    end
    result true, 'Created Successfully'
  end

  def update_record(data)
    vendor = self.company.yes_bank_vendors.find_by id: data[:id]
    unless vendor
      return result false, "Vendor not found"
    end
    vendor_params, messages = set_params(data)
    unless messages.blank?
      return result false, messages.join(', ')
    end

    vendor.assign_attributes(vendor_params["vendor"].except("gstin_locations_attributes", "bank_accounts_attributes", "status_id"))
    if vendor_params["vendor"]["bank_accounts_attributes"].present?
      bank_account = vendor.bank_accounts.first
      if bank_account.present?
        bank_account.assign_attributes(vendor_params["vendor"]["bank_accounts_attributes"]&.first)
        unless bank_account.validate
          return result false, bank_account.errors.full_messages
        end
      end
    end

    if vendor_params["vendor"]["gstin_locations_attributes"].present?
      gstin_location = vendor.gstin_locations.first
      if gstin_location.present?
        gstin_location.assign_attributes(vendor_params["vendor"]["gstin_locations_attributes"]&.first)
        unless gstin_location.validate
          return result false, gstin_location.errors.full_messages
        end
      end
    end

    unless vendor.validate
      return result false, vendor.errors.full_messages
    end

    if vendor.save
      bank_account.save if bank_account.present?
      gstin_location.save if gstin_location.present?
    else
      return result false, vendor.errors.full_messages
    end
    result true, 'Updated Successfully'
  end

  def destroy_records(data)
   vendor = self.company.yes_bank_vendors.find_by id: data[:id]
   unless vendor
    return result false, "vendor not found"
   end
   unless vendor.destroy
     return result false, vendor.errors.full_messages
   end
   result true, "Destroyed Successfully"
  end
  
  def set_params(data)
    messages =[]
    business_name = data[:business_name].to_s
    messages << "Legal Name can't Blank" if business_name.blank?
    mobile_number = clean_up_data data[:mobile_number]
    email = data[:email].to_s
    trade_name = data[:trade_name].to_s
    pan = data[:pan].to_s
    state =data[:state].to_s
    description = data[:description].to_s
    address = data[:address].to_s
    created_by_id = self.company.users.only_admins&.first&.id
    account_number = clean_up_data data[:account_number]
    account_name = data[:vendor_bank_account_name]
    ifsc = data[:ifsc].to_s
    gstin = data[:gstin].to_s
    location = data[:gst_location].to_s
    code = data[:vendor_id].to_s
    vendor_id = (code.blank? ? nil : code)
    vendor_type_id = nil
    if data[:vendor_type].present?
      vendor_type_id = company.vendor_types.where(name: data[:vendor_type]).first
      if vendor_type_id.blank?
        vendor_type = company.vendor_types.create(name: data[:vendor_type])
        vendor_type_id = vendor_type.id
      end
    end

    gstin_state_id = nil
    if gstin.present?
      gstin_state_id = GstStateCode.where(state_code: gstin[0..1])&.first&.id
    end

    if gstin_state_id.nil? && state.present?
      gstin_state_id = GstStateCode.where('name LIKE ?', "%#{state}%")&.first&.id
    end

    if gstin.present? || state.present? || location.present?
      messages << "GST State is unable to match" if gstin_state_id.nil?
    end

    gst_registered = (gstin.present? ? true : false)
    params = {"vendor" => {"business_name" => business_name,
                           "authorized" => "1",
                           "mobile_number" => mobile_number,
                           "email" => email,
                           "currency_id" => "1",
                           "trade_name" => trade_name,
                           "pan" => pan,
                           "description" => description,
                           "address" => address,
                           "status_id" => 6,
                           "created_by_id" => created_by_id,
                           "vendor_id" => vendor_id,
                           "vendor_type_id" => vendor_type_id,
                           "gst_registered" => gst_registered
    }}

    bank_params={"bank_accounts_attributes" =>[{"name"=>account_name,
                                                "account_number"=>account_number,
                                                "ifsc"=> ifsc,
                                                "default_account"=>"1"}]}

    gstin_locations={"gstin_locations_attributes" => [{"location" =>location,
                                                       "gstin"=>gstin,
                                                       "poc_mobile_number" => mobile_number,
                                                       "poc_email" => email,
                                                       "address" => address,
                                                       "state_id"=> gstin_state_id}]}

    if account_number.present? || account_name.present? || ifsc.present?
      params["vendor"]["bank_accounts_attributes"] = bank_params["bank_accounts_attributes"]
    end

    if location.present? || gstin.present? || gstin_state_id.present? || mobile_number.present? || email.present? || address.present?
      params["vendor"]["gstin_locations_attributes"] = gstin_locations["gstin_locations_attributes"]
    end
    [params, messages]
  end

  def clean_up_data(text)
    if text.is_a?(Float)
      text.to_i&.to_s
    elsif text.is_a?(Integer)
      text.to_s
    else
      text&.strip
    end
  end

  def check_existing_vendor(vendor_params)
    return false if vendor_params["vendor_id"].blank?
    existing_vendor = company.yes_bank_vendors.non_deleted.find_by_vendor_id vendor_params["vendor_id"]
  end

  def check_existing_location(vendor, gstin_location_params)
    return false if gstin_location_params["gstin"].blank?
    vendor.gstin_locations.where(gstin: gstin_location_params["gstin"]).blank?
  end
end
