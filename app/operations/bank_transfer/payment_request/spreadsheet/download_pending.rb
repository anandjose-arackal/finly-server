class BankTransfer::PaymentRequest::Spreadsheet::DownloadPending < BankTransfer::PaymentRequest::Spreadsheet::Base

  def init
    self.view_role = UserRole.id_for(params[:view]&.to_sym)
    op = BankTransfer::PaymentRequest::Index.(user, params)
    if op.success?
      self.bank_payment_requests = op.payment_requests
      self.bank_payment_requests = self.bank_payment_requests.with_controlling_user(user.id)
    else
      add_message :error, op.messages[:error]
    end
  end

end
