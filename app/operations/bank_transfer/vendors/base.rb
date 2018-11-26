class BankTransfer::Vendors::Base < BaseOperation

  attr_accessor :company, :vendor

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    self.company = user.company
  end

  def success
    params[:vendor] = vendor
    BankTransfer::Vendors::Base::VendorsPresenter.new(user, params, messages)

  end

  class BankTransfer::Vendors::Base::VendorsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :vendor

    def init
      self.vendor = params[:vendor]
    end
  end

  protected

  def vendor_attributes
    params.require(:vendor).permit(:name, :email, :mobile_number, :authorized, :description, :pan, :tin, :gst, :state, :state_code_id, :gst_registered, :vendor_type_id,
                                   :business_name, :address, :payment_term_id, :currency_id, :tds_rates_list_id,
                                   bank_accounts_attributes: [:account_number, :ifsc, :name, :default_account, :address_1, :address_2, :address_3, :pin_code, :country],
                                   vendor_attachments_attributes: [:attached_file, :attachment_type, :remove_file],
    )
  end

  def validate_custom_fields
    if self.vendor.valid?
      set_fields = set_custom_fields false
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

  def set_custom_fields(save)
    custom_fields = {custom_fields: (params[:custom_fields] or params[:expense][:custom_fields])}
    custom_fields[:user] = user
    custom_fields[:reset_fields] = true
    custom_fields[:save] = save
    CustomField::SetFields.(self.vendor, FieldParentType.id_for(:vendor), custom_fields)
  end

end

