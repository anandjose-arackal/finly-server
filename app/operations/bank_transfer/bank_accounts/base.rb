class BankTransfer::BankAccounts::Base < BaseOperation

  attr_accessor :bank_account

  def authorized_user_types
    [:company_admin]
  end

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def bank_account_params
    params.require(:bank_account).permit(:account_number, :ifsc, :name, :address_1, :address_2, :pin_code, :country)
  end
end
