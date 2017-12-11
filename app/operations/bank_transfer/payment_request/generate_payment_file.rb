class BankTransfer::PaymentRequest::GeneratePaymentFile < BankTransfer::PaymentRequest::Base

  attr_accessor :bank_payment_requests, :payment_file_data

  def pre_validate
    super
    if params[:bank_payment_request_ids].blank?
      add_message :error, "Payment order ids not passed"
      return
    end
  end

  def init
    # the input here will be either a comma separated set of values or
    ids = params[:bank_payment_request_ids]
    unless ids.is_a?(Array)
      ids = ids.split(",")
    end
    self.bank_payment_requests = BankTransfer::PaymentRequest::Index.(user, params).payment_requests.with_id(ids) rescue nil
    # self.bank_payment_requests = BankPaymentRequest.where(id: ids)
  end

  def validate
    unless current_company.payment_file_configuration.present?
      add_message :error, "Payment file has not been configured for your company yet"
    end
  end

  def process
    data = []
    bank_payment_requests.each do |request|
      request.payment_order.payments.each do |payment|
        data << {
            beneficiary_account_number: payment.receiving_account.account_number,
            receiving_user_name: payment.receiving_user.name,
            amount: payment.amount_value,
            date: Date.today.strftime("%d-%^b-%Y"),
            ifsc: payment.receiving_account.ifsc,
            email: payment.receiving_user.email,
            note: payment.note,
            payment_mode: payment.payment_mode
        }
      end
    end
    self.response = PaymentFiles::Generate.(user, {payment_file: data})
  end

  def post_process
    # marking these payment requests as payment file downloaded
    self.bank_payment_requests.each do |payment_request|
      payment_request.update(payment_file_downloaded: true)
    end

    add_message :success, "Payment file successfully downloaded"
  end

end