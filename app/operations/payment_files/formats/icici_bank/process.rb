class PaymentFiles::Formats::IciciBank::Process < PaymentFiles::Formats::BaseFormat

  attr_accessor :payment_requests, :debit_account_number

  def pre_validate
    super
    return if has_errors?
  end

  def init
    super
    self.payment_requests = params[:bank_payment_requests]
    self.debit_account_number = self.options[:debit_account_number]
  end

  def validate
    result = PaymentFiles::Formats::YesBank::ValidateConfig.(user, {options: self.options, config: self.config})
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
  end

  def process
    headers = retrieve_icici_headers
    content = []
    self.payment_requests.each do |request|
      order = request.payment_order
      order.payments.each do |payment|
        content << [
            self.debit_account_number,
            payment.receiving_account.account_number,
            payment.receiving_user&.name,
            payment.amount_value,
            "N", # todo - change this based on the payment mode - have to find out what the characters are for other payment modes
            payment.invoice&.date&.strftime("%d-%^b-%Y"),
            payment.receiving_account.ifsc,
            "",
            "",
            payment.receiving_user.mobile_number,
            payment.receiving_user.email,
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            payment.note
        ]
      end
    end
    debugger
    self.response = Exporter.new(user, {spreadsheet: {headers: headers, contents: contents, template: "#{Rails.root}/app/operations/payment_files/formats/icici_bank/template.xls.erb"}}, messages)
  end

  def retrieve_icici_headers
    ["Debit Ac No", "Beneficiary Ac No", "Beneficiary Name", "Amt", "Pay Mod", "Date", "IFSC", "Payable Location", "Print Location", "Bene Mobile No.", "Bene Email ID", "Bene add1", "Bene add2", "Bene add3", "Bene add4", "Add Details 1", "Add Details 2", "Add Details 3", "Add Details 4", "Add Details 5", "Remarks"]
  end
end