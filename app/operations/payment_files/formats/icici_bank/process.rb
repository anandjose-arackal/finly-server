class PaymentFiles::Formats::IciciBank::Process < PaymentFiles::Formats::BaseFormat

  attr_accessor :payment_requests, :debit_account_number

  def pre_validate
    return if has_errors?
  end

  def init
    super
    self.payment_requests = params[:bank_payment_requests]
    self.debit_account_number = self.options[:debit_account_number]
  end

  def validate
    result = PaymentFiles::Formats::IciciBank::ValidateConfig.(user, {options: self.options, config: self.config})
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
  end

  def process
    self.headers = retrieve_icici_headers
    content = []
    self.payment_file_data.each do |payment|
      content << [
          self.debit_account_number,
          payment[:beneficiary_account_number],
          payment[:receiving_user_name],
          payment[:amount],
          retrieve_payment_mode(payment),
          payment[:date],
          payment[:beneficiary_ifsc],
          "",
          "",
          payment[:receiving_mobile_number],
          payment[:receiving_user_email],
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
          payment[:note]
      ]
      # Todo Remove the last entry of "payment[:initiating_user_email]", this was specifically built as per Toppr's requirements
    end
    self.contents = content
  end

  def success
    generate_export_file
  end

  def retrieve_icici_headers
    # Todo Remove the last entry of "Initiating User Email", this was specifically built as per Toppr's requirements
    ["Debit Ac No", "Beneficiary Ac No", "Beneficiary Name", "Amt", "Pay Mod", "Date", "IFSC", "Payable Location", "Print Location", "Bene Mobile No.", "Bene Email ID", "Bene add1", "Bene add2", "Bene add3", "Bene add4", "Add Details 1", "Add Details 2", "Add Details 3", "Add Details 4", "Add Details 5", "Remarks"]
  end

  def retrieve_payment_mode(payment)
    case payment[:payment_mode].upcase
      when "NEFT"
        return "N"
      when "IMPS"
        return "I"
      when "RTGS"
        return "R"
      else
        # default to "N"
        return "N"
    end
  end
end