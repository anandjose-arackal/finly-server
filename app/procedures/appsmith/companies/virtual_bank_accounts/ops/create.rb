class Appsmith::Companies::VirtualBankAccounts::Ops::Create < Transactions::API
    
    step :find_utility_bill_account_and_execute_va_generate

    def find_utility_bill_account_and_execute_va_generate(options,params:,**)
        UtilityBillsAccount.find_by(company_id: params[:company_id]).va_generate
    end

end
