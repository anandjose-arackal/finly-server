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
    # self.bank_payment_requests = BankTransfer::PaymentRequest::Index.(user, params).payment_requests.approved.with_id(ids) rescue nil
    self.bank_payment_requests = BankTransfer::PaymentRequest::Index.(user, params).payment_requests.downloadable.with_id(ids) rescue nil
    # self.bank_payment_requests = BankPaymentRequest.where(id: ids)
  end

  def validate
    unless current_company.payment_file_configuration.present?
      add_message :error, "Payment file has not been configured for your company yet"
      return
    end
  end

  def process
    data = []
    bank_payment_requests.each do |request|
      request.payment_order.payments.each do |payment|
        data << {
            beneficiary_account_name: payment.receiving_account.name,
            beneficiary_account_number: payment.receiving_account.account_number,
            beneficiary_ifsc: payment.receiving_account.ifsc,
            initiating_user_name: payment.initiating_user&.name,
            initiating_user_email: payment.initiating_user&.email,
            initiating_user_mobile_number: payment.initiating_user&.mobile_number,
            receiving_user_name: payment.receiving_user.display_name,
            receiving_user_email: payment.receiving_user.email,
            receiving_user_mobile_number: payment.receiving_user.mobile_number,
            amount: payment.amount_value,
            date: Date.today.strftime("%d-%^b-%Y"),
            note: generate_payment_note(payment),
            payment_mode: payment.payment_mode
        }
      end
    end
    self.response =   PaymentFiles::Generate.(user, {payment_file: data, resources: self.bank_payment_requests})
  end

  def generate_payment_note(payment)
    # generates payment note from invoice line items's description
    note = ""
    payment.invoice&.invoice_items&.each do |item|
      unless note.blank?
        note += ", "
      end
      note += item.description
    end

    note

  end

  def post_process
    # marking these payment requests as payment file downloaded
    self.bank_payment_requests.each do |payment_request|
      payment_request.update(payment_file_downloaded: true)
    end

    add_message :success, "Payment file successfully downloaded"
  end
end