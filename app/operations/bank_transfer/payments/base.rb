class BankTransfer::Payments::Base < BaseOperation

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def retrieve_initiating_account(company)
    case company&.feature_subscription&.bank_service_provider
    when "YES"
      initiating_account = user.company.yes_bank_company_account
    when "ICICI"
      initiating_account = user.company.icici_bank_company_account
    when "KOTAK"
      initiating_account = user.company.kotak_bank_company_account
    else
      initiating_account = user.company.yes_bank_company_account
    end
    initiating_account
  end

end