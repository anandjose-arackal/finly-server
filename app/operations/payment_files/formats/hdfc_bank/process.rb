class PaymentFiles::Formats::HdfcBank::Process < PaymentFiles::Formats::BaseFormat

  attr_accessor :payment_requests

  def pre_validate
    return if has_errors?
  end

  def init
    super
    self.payment_requests = params[:bank_payment_requests]
  end

  def validate
    result = PaymentFiles::Formats::HdfcBank::ValidateConfig.(user, {options: self.options, config: self.config})
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
  end

  def process
    headers = retrieve_kotak_headers
    content = []
    sl_no = 0
    self.payment_file_data.each do |payment|
      sl_no += 1
      content << [
          self.client_code,
          self.product_code,
          payment[:payment_mode],
          "",
          Date.parse(payment[:date]).strftime("%d-%m-%Y"),
          self.debit_account_number,
          payment[:amount],
          "",
          payment[:receiving_user_name],
          payment[:beneficiary_ifsc],
          payment[:beneficiary_account_number],
          payment[:receiving_user_email],
          payment[:receiving_mobile_number],
          payment[:note]
      ]
    end
    self.response = Exporter.new(user, {spreadsheet: {headers: headers, contents: content}}, messages)
  end

  def retrieve_kotak_headers
    [
        
    ]
  end
end