class PaymentFiles::Formats::IciciBank::Process < PaymentFiles::Formats::BaseFormat

  def pre_validate
    super
    return if has_errors?
  end

  def init
    super

  end

  def validate
    super
    result = PaymentFiles::Formats::YesBank::ValidateConfig.(user, {options: self.options, config: self.config})
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
  end

  def process
    headers = retrieve_icici_headers
    content = []
  end

  def retrieve_icici_headers
    ["Debit Ac No", "Beneficiary Ac No", "Beneficiary Name", "Amt", "Pay Mod", "Date", "IFSC", "Payable Location", "Print Location", "Bene Mobile No.", "Bene Email ID", "Bene add1", "Bene add2", "Bene add3", "Bene add4", "Add Details 1", "Add Details 2", "Add Details 3", "Add Details 4", "Add Details 5", "Remarks"]
  end
end