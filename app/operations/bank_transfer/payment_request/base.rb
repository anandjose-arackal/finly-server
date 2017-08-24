class BankTransfer::PaymentRequest::Base < BaseOperation

  def retrieve_initiating_account
    if user.company_admin?
      case params[:initiating_account_type]
        when 1, '1', "CompanyAccount"
          self.initiating_account = user.company.yes_bank_company_account
        when 2, '2', "FinlyCredits"
          self.initiating_account = user.bank_wallet
      end
    else
      self.initiating_account = user.bank_wallet
    end
  end
end