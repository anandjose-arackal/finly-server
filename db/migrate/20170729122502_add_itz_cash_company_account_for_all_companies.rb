class AddItzCashCompanyAccountForAllCompanies < ActiveRecord::Migration
  def change
    Company.all.each do |company|
      op = ItzCash::VirtualAccountBalance.(company)
      if op.success?
        balance = op.wallets.first[:balance]
        company.build_itz_cash_company_account(balance_attributes: {value: balance, currency_id: 1}, wallet_balance_attributes: {value: 0, currency_id: 1}).save
      end
      company.build_yes_bank_company_account(balance_attributes: {value: 0, currency_id: 1}, wallet_balance_attributes: {value: 0, currency_id: 1}).save
    end
  end
end
