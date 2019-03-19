class Vendors::Base < BaseOperation
  attr_accessor :vendor, :workflow_output, :company

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    self.company = user.company
    id = params[:vendor_id] || params[:yes_bank_vendor_id] || params[:id] 
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
                                   :business_name, :address, :payment_term_id, :currency_id, :tds_rates_list_id, :policy_id,
                                   bank_accounts_attributes: [:account_number, :ifsc, :name, :default_account, :address_1, :address_2, :address_3, :pin_code, :country],
                                   vendor_attachments_attributes: [:attached_file, :attachment_type, :remove_file],
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
end