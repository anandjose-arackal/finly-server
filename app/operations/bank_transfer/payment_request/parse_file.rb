# Parse_file parses the given file and extract the users and amounts
class BankTransfer::PaymentRequest::ParseFile < BankTransfer::PaymentRequest::Base
  attr_accessor :file, :parsed_data, :response_presenter

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or params[:file].blank?
      add_message :error, 'Error loading file. File not uploaded correctly'
      return
    end
  end

  def init
    self.file = params[:file]
    self.parsed_data = ImportUtil.load_spreadsheet(file, [:name, :bank_account_number, :ifsc, :original_amount,
                                                                :inclusive_of_taxes, :gst_type_id, :tax_type_id, :tax, :discount_type_id,
                                                                :discount, :tds_type_id, :tds, :invoice_number, :invoice_date, :due_date], {skip_empty_lines: true})
  end

  def validate
    if parsed_data.blank?
      add_message :error, 'Nothing to process'
    end
  end

  def process
    params[:payment_order] = self.parsed_data
    self.response_presenter = BankTransfer::PaymentRequest::Process.(user, params)
  end

  def success
    self.response_presenter
  end

  def failure
    self.response_presenter || super
  end

end

