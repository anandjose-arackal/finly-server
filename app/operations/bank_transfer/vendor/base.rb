class BankTransfer::Vendor::Base < BaseOperation

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
    BankTransfer::Vendor::Base::VendorPresenter.new(user, params, messages)

  end

  class BankTransfer::Vendor::Base::VendorPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :vendor

    def init
      self.vendor = params[:vendor]
    end
  end

  protected

  def vendor_attributes
    params.require(:vendor).permit(:name, :email, :mobile_number,
                                   bank_accounts_attributes: [:account_number, :ifsc, :name, :address_1, :address_2, :address_3, :pin_code, :country])
  end
end

