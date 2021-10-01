class Appsmith:: Companies::VirtualBankAccounts::Create < Appsmith::Companies::VirtualBankAccounts::Base

    def pre_validate
      if Rails.env.production?
        add_message :error, 'Cannot perform action'
      end
    end

    def validate
      if UtilityBillsAccount.find_by(company_id: params[:company_id]).virtual_bank_account
        add_message :error, 'Virtual bank account already existed'
      end
    end

    def process
      ::Invoicing::VirtualBankAccount::Create.(nil, {application: nil, company: nil, parent: self, purpose_id: nil, receiving_account: self})
    end

    def success
      BaseOperation::BasePresenter::SuccessPresenter.new(user, params, messages)
    end
    
end