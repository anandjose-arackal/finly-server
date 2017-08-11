class BankTransfer::Vendor::Base < BaseOperation

  attr_accessor :company

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    self.company = user.company
  end

  protected

  def vendor_attributes
    params.require(:vendor).permit(:name, :email, :mobile_number,
                                   bank_accounts_attributes: [:account_number, :ifsc, :name, :address_1, :address_2, :address_3, :pin_code, :country])
  end
end

