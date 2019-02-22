class Admin::Companies::Base < Admin::Base

  def pre_validate
    super()
  end

  def company_params
    params.require(:company).permit(:status_id, :name, itz_cash_property_attributes: [:d_code], configuration_attributes: [:logo, :registered_mobile_number],
                                    company_kyc_attributes: [:company_type_id, :customer_type_id],
                                    feature_subscription_attributes: [
                                      :ocr_enabled,
                                      :expense_management_enabled,
                                      :gift_card_enabled,
                                      :gift_voucher_enabled,
                                      :meal_card_enabled,
                                      :fuel_card_enabled,
                                      :medical_card_enabled,
                                      :expense_card_enabled,
                                      :reimbursement_card_enabled,
                                      :itz_cash_d_code_enabled,
                                      :hard_copy_receipt,
                                      :yes_bank_account,
                                      :bank_account_reimbursement,
                                      :payroll_card_enabled,
                                      :invoicing_system,
                                      :em_tax_tracking,
                                      :procurement,
                                      :travel_request,
                                      :budgeting_system,
                                      :invoicing_system
    ])
  end

  def success
    Admin::Companies::Base::CompanyPresenter.new(user, {company: company}, messages)
  end

  class Admin::Companies::Base::CompanyPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :company

    def init
      self.company = params[:company]
    end

    def itz_cash_company_balance
      # op = Admin::Companies::ItzCashBalance.(user, {company: company})
      # op&.success? ? op.balance : nil
      itz_cash_adapter = AccountManager::ItzCashAccount::ItzCashCompanyAccountAdapter.new(company.itz_cash_company_account)
      return itz_cash_adapter.balance
    end

    def yes_bank_company_balance
      # calling the adapter for balance
      yes_bank_adapter = AccountManager::YesBankAccount::YesBankCompanyAccountAdapter.new(company.yes_bank_company_account)
      return yes_bank_adapter.balance
    end
  end

end