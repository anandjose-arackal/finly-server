class PaymentFiles::Formats::HsbcBank::Process < PaymentFiles::Formats::BaseFormat

  attr_accessor :payment_requests, :debit_account_number, :second_email, :third_email

  def pre_validate
    return if has_errors?
  end

  def init
    super
    self.payment_requests = params[:bank_payment_requests]
    self.debit_account_number = self.options[:debit_account_number]
    self.second_email = self.options[:second_email]
    self.third_email = self.options[:third_email]
  end

  def validate
    result = PaymentFiles::Formats::HsbcBank::ValidateConfig.(user, {options: self.options, config: self.config})
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
  end

  def process
    self.headers = retrieve_hsbc_headers
    content = []
    self.payment_file_data.each do |payment|
      content << [
          "NEFT",
          "",
          debit_account_number,
          payment[:note],
          payment[:receiving_user_name],
          "",
          "",
          "",
          "",
          "",
          Date.today.strftime("%d/%m/%Y"),
          payment[:amount],
          "",
          payment[:receiving_user_email],
          second_email,
          third_email,
          "",
          "",
          "",
          "",
          "",
          "",
          payment[:beneficiary_account_number],
          payment[:beneficiary_ifsc]
      ]
    end
    self.contents = content
  end

  def success
    generate_export_file
  end

  def retrieve_hsbc_headers
    ["Transaction Type",	"Reference Number",	"Dr Account No",	"Payment Narration",	"Beneficiary Name",	"Bene Add 1",
     "Bene Add 2",	"Bene Add 3",	"Payment Location",	"Cheque No",	"Value Date",	"Amount",	"Print Branch Location",
     "Email Add-1",	"Email Add-2",	"Email Add-3",	"FreeText",	"NA",	"NA",	"NA",	"NA","NA",	"Bene Bank Account #",
     "Bene Bank IFSC /  BANK Code",	"NA",	"Deliver To",	",Ordering Party Name",	"Ordering_Party Add1",	"Ordering_Party Add2",
     "Ordering_Party Add3",	",Ordering_party_Account",	"BANK_NAME",	"Bank_to_Bank_Info"]
  end


end