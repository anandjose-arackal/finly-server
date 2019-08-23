class Admin::Implementations::Master::Vendors::Import < Admin::Implementations::Processor::Import

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'vendors.import'
  headers ({
      :id => "ID",
      :name => "Vendor NAme",
      :vendor_type => "Vendor Type",
      :vendor_id => "Vendor Code",
      :business_name => "Business Name",
      :mobile_number => "Mobile Number",
      :email => "Email",
      :pan => "PAN",
      :state => "State",
      :description => "Description",
      :address => "Address",
      :gstin => "GSTIN",
      :gst_location => "GST Location",
      :vendor_bank_account_name => "Bank Account Name",
      :account_number => "IFSC",
      :destroy => "Destroy"
  })

  attr_accessor :vendor_params

  def create_record(data)
    vendor_params, messages = set_params(data)
    unless messages.blank?
      return result false, messages.join(', ')
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
    unless vendor.update(vendor_params["vendor"])
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
    name = data[:name].to_s
    messages << "Name can't Blank" if name.blank?
    mobile_number = clean_up_data data[:mobile_number]
    email = data[:email].to_s
    business_name = data[:business_name].to_s
    pan = data[:pan].to_s
    state_code_id = nil
    state_code_id = State.where("name LIKE ?", "%"+data[:state].to_s+"%").first&.id if !data[:state].to_s.blank?
    description = data[:description].to_s
    address = data[:address].to_s
    created_by_id = self.company.users.only_admins&.first&.id
    account_number = clean_up_data data[:account_number]
    account_name = data[:vendor_bank_account_name]
    if account_name.blank?
      account_name = "#{business_name}'s Account'"
    end
    ifsc = data[:ifsc].to_s
    gstin = data[:gstin].to_s
    location = data[:gst_location].to_s
    code = data[:vendor_id].to_s
    vendor_id = (code.blank? ? nil : code)
    if data[:vendor_type].present?
      vendor_type_id = company.vendor_types.where(name: data[:vendor_type]).first
      messages << "Vendor Type not Created in system" if vendor_type_id.nil?
    end
    vendor_type_id = data[:vendor_type].to_s
    state_code_id = nil
    state_code_id = State.where("name LIKE ?", "%"+data[:state].to_s+"%").first&.id if !data[:business_name].to_s.blank?

    gstin_state_id = nil
    if gstin.present?
      gstin_state_id = GstStateCode.where(state_code: gstin[0..1])&.first&.id
    end

    if gstin_state_id.nil? && location.present?
      gstin_state_id = GstStateCode.where('name LIKE ?', "%#{location}%")&.first&.id
    end

    messages << "GST State is unable to match" if gstin_state_id.nil?

    gst_registered = (gstin.present? ? true : false)

    params =  {"vendor"=>{"name"=> name,
                          "authorized"=>"1",
                          "mobile_number"=> mobile_number,
                          "email"=> email ,
                          "currency_id"=>"1",
                          "business_name"=> business_name,
                          "pan"=> pan,
                          "state_code_id"=> state_code_id,
                          "description"=> description,
                          "address"=> address,
                          "status_id"=> 6,
                          "created_by_id"=> created_by_id,
                          "vendor_id" => vendor_id,
                          "vendor_type_id" => vendor_type_id,
                          "gst_registered" =>  gst_registered
    }}

    bank_params={"bank_accounts_attributes" =>[{"name"=>account_name,
                                                "account_number"=>account_number,
                                                "ifsc"=> ifsc,
                                                "default_account"=>"1"}]}

    gstin_locations={"gstin_locations_attributes" => [{"location" =>location,
                                                       "gstin"=>gstin,
                                                       "poc_mobile_number" => mobile_number,
                                                       "poc_mobile_number" => email,
                                                       "address" => address,
                                                       "state_id"=> gstin_state_id}]}

    if account_number.present?
      params["vendor"]["bank_accounts_attributes"] = bank_params["bank_accounts_attributes"]
    end

    if location.present?
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
end
