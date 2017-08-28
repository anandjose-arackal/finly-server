class BankTransfer::PaymentRequest::Base < BaseOperation

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
      return
    end
  end

  def retrieve_initiating_account
    if user.company_admin?
      case params[:initiating_account_type]
        when 1, '1', "CompanyAccount"
          self.initiating_account = user.company.yes_bank_company_account
        when 2, '2', "FinlyCredits"
          self.initiating_account = user.bank_wallet
        else
          # do nothing?
      end
    else
      self.initiating_account = user.bank_wallet
    end
  end
end