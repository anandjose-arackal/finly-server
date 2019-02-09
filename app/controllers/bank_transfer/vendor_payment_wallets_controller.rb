class BankTransfer::VendorPaymentWalletsController < BaseControllers::WebBase


  def update_balance
    action_type = params[:type] || params[:action_type] rescue nil
    case action_type
      when 'credit', :credit
        # Value = 1
        @result = BankTransfer::VendorPaymentWallet::Credit.(current_user, params)
      when 'debit', :debit
        # Value = 2
        @result = BankTransfer::VendorPaymentWallet::Debit.(current_user, params)
    end
    respond
  end

  def transfer_options
    @result = BankTransfer::VendorPaymentWallet::TransferOptions.(current_user, params)
    respond
  end
end
