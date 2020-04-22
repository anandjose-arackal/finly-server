# Expected format
# {
#     payment_file: [
#         {
#             email: 'email@id.com',
#             mobile_number: '9989989898',
#             bank_account: '<bank_account>',
#             amount: <amount class>,
#         }
#     ]
# }
class PaymentFiles::Formats::BaseFormat < BaseOperation
  attr_accessor :payment_file_data, :config, :options, :export_file_path, :contents, :headers

  def pre_validate
    if params&.dig(:payment_file).nil?
      add_message :error,'Payment data not found'
      return
    end
  end

  def init
    self.payment_file_data = params[:payment_file]
    self.config = user.company.payment_file_configuration
    self.options = self.config&.options
  end

  def validate
    if self.payment_file_data.nil?
      add_message :error,'Payment data not found'
      return
    end
    self.payment_file_data.each do |data|
      unless data[:bank_account].present? and data[:bank_account].class.name == BankAccount.name
        add_message :error, 'Invalid Data: Bank Account not found'
        return
      end
      unless data[:amount].present? and data[:amount].class.name == Amount.name
        add_message :error, 'Invalid Data: Amount not valid'
        return
      end
    end
  end

  def generate_export_file
    operation = Exporter::Spreadsheet.new(user, {headers: self.headers, contents: self.contents}, messages)
    params[:type].present?
    if %w(csv CSV).include?(params[:type])
      file = operation.generate_csv_file
    else
      file = operation.generate_xls_file
    end
    # Create a temporary file to save it to s3 and provide the download link to frontend
    temp_file = TemporaryFile.create file: file, expires_on: (DateTime.now.beginning_of_day + 7.days)
    file.close
    file.unlink
    self.export_file_path = temp_file.file.url
    params[:file_url] = export_file_path
    PaymentFiles::Formats::BaseFormat::FilePresenter.new(user, params, messages)
  end

  class PaymentFiles::Formats::BaseFormat::FilePresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :file_url, :success

    def init
      self.file_url = params[:file_url]
      self.success = true
    end
  end

end