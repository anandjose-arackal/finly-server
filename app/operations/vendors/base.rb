class Vendors::Base < BaseOperation
  attr_accessor :vendor, :workflow_output, :company

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    self.company = user.company
    # id = params[:vendor_id] || params[:yes_bank_vendor_id] || params[:id] 
    self.vendor = Vendors::Show.(user, params).vendor
  end

  def validate
    unless self.vendor.present?
      add_message :error, "Vendor not found"
    end
  end


  protected

  def vendor_attributes
    params.require(:vendor).permit(:name, :email, :mobile_number, :authorized, :description, :pan, :tin, :gst, :state, :state_code_id, :gst_registered, :vendor_type_id,
                                   :business_name, :address, :payment_term_id, :currency_id, :policy_id, :vendor_id, :override_vendor_id,
                                   vendor_tds_rates_attributes: [:id, :tds_rates_list_id, :_destroy],
                                   bank_accounts_attributes: [:id, :account_number, :ifsc, :name, :default_account, :bank_account_master_id, :_destroy],
                                   vendor_attachments_attributes: [:id, :attached_file, :attachment_type, :_destroy],
                                   gstin_locations_attributes: [:id, :gstin_id, :gstin, :location, :state_id, :poc_name, :poc_email, :poc_mobile_number, :poc_fax, :poc_designation, :address, :_destroy]
    ) 
  end

  def validate_custom_fields(reset_fields = false)
    if self.vendor.valid?
      set_fields = set_custom_fields false, reset_fields
      unless set_fields.success?
        add_message :error, set_fields.messages[:error]
        return
      end
      valid = CustomField::Validate.(self.vendor)
      unless valid.success?
        add_message :error, valid.messages[:error]
        return
      end
    end
  end

  def set_custom_fields(save, reset_fields = false)
    custom_fields = {custom_fields: (params[:custom_fields] or params&.dig(:vendor, :custom_fields))}
    custom_fields[:user] = user
    custom_fields[:reset_fields] = reset_fields
    custom_fields[:save] = save
    CustomField::SetFields.(self.vendor, FieldParentType.id_for(:vendor), custom_fields)
  end

  # def validate_business_name(vendor_params)
  #   business_name = vendor_params[:business_name]
  #   vendor_params[:gstin_locations_attributes].each_with_index do |gstin_location, index|
  #     gstin = gstin_location[:gstin]

  #     unless gstin.present?
  #       add_message :error, "Please Provide GSTIN for Location #{index+1}"
  #       next
  #     end

  #     gstin_master = Gstin.with_gstin(gstin).first

  #     if gstin_master.present?
  #       match_percentile = fuzzy_string_match(business_name, gstin_master.legal_name_of_business)

  #       if match_percentile < 90
  #         add_message :error, "Business Name Match Percentile is below 90% for Location #{index+1}"
  #       end
  #     end
  #   end
  # end

  def validate_gstin(vendor_params)
    business_name = vendor_params[:business_name]
    vendor_params[:gstin_locations_attributes].each_with_index do |gstin_location, index|
      gstin = gstin_location[:gstin]

      unless gstin.present?
        add_message :error, "Please Provide GSTIN for Location #{index+1}"
        next
      end

      gstin_master = Gstin.with_gstin(gstin).first

      if gstin_master.present?
        gstin_location[:gstin_id] = gstin_master.id
        if gstin_master.status == "Active"

          unless gstin_master.gstin.slice(2, 10) == vendor_params[:pan]
            add_message :error, "PAN doesn't match with GSTIN for Location #{index+1}"
          end

          match_percentile = StringUtils.fuzzy_string_match(business_name, gstin_master.legal_name_of_business)
          trade_name_match_percentile = StringUtils.fuzzy_string_match(business_name, gstin_master.trade_name)

          if match_percentile < 90 && trade_name_match_percentile < 90
            add_message :error, "Business Name or Trade Name Match Percentile is below 90% for Location #{index+1}"
          end
        else
          add_message :error, "GSTIN Status is not Active for Location #{index+1}"
        end
      end
    end
  end

  def validate_attachment(vendor_params, type)
    # Checks presence of attachment with passed type
    types = {pan: "PAN", gstin: "GSTIN Certificate", cancelled_cheque: "Cancelled Cheque", tax_exemption: "Tax Exemption Certificate", lower_exemption: "Lower Exemption Certificate", msme_certificate: "MSME Certificate", others: "Others"}

    # attachment_name = 
    if vendor_params.present? && vendor_params[:vendor_attachments_attributes].present?
      if self.vendor.present? && self.vendor.vendor_attachments.with_type(type).present?
        # do nothing
      elsif find_attachment(vendor_params[:vendor_attachments_attributes], type)
        add_message :error, "Please upload #{types[type]}"
      else
        add_message :error, "Please upload #{types[type]}"
      end
    elsif self.vendor.present? && self.vendor.vendor_attachments.with_type(type).present?
      # do nothing
    else
      add_message :error, "Please upload #{types[type]}"
    end
  end

  def find_attachment(attachment_params, type)
    found = false
    attachment_params.each do |attachment|
      if attachment[:attachment_type] == type.to_s && !(attachment[:_destroy].present?)
        found = true
        break
      end
    end
    found
  end
end