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
                                   :business_name, :address, :payment_term_id, :currency_id,
                                   bank_accounts_attributes: [:account_number, :ifsc, :name, :default_account, :address_1, :address_2, :address_3, :pin_code, :country],
                                   vendor_attachments_attributes: [:attached_file, :type, :remove_file],
    )
  end
end

