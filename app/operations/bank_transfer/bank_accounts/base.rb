class BankTransfer::BankAccounts::Base < BaseOperation

  attr_accessor :bank_account

  class BankTransfer::BankAccounts::Base::BankAccountPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :bank_account

    def init
      self.bank_account = params[:bank_account]
    end
  end

  # def authorized_user_types
  #   [:company_admin, :finance_manager, :manager, :personal]
  # end

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def bank_account_params
    params.require(:bank_account).permit(:account_number, :ifsc, :default_account, :name, :address_1, :address_2, :pin_code, :country)
  end
end
