class Admin::BankTransfer::GetBulkStatus < Admin::Base

  attr_accessor :file_url, :file, :result_hash, :params, :missing_params, :sheet, :header, :transaction_params

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters. please try again"
    end
  end

  def init
    self.file = params[:file]
    self.result_hash = {}
    if file.present?
      self.sheet = ImportUtil.open_spreadsheet(file)
      self.header = sheet.row(1)
    end
  end

  def validate
    if file.nil? || sheet.nil?
      add_message :error, "No file uploaded, please attach a file and try again"
    end
  end

  def process
    (2..sheet.last_row).each do |i|
      row = sheet.row(i)
      self.transaction_params = process_row(row)

      operation = Admin::BankTransfer::GetStatus.(user, self.transaction_params)
      if operation.success?
        result_hash[i] = {
            bank_reference_number: operation.transaction.bank_reference_number,
            status: operation.status,
            amount: operation.transaction.amount.value,
            error: operation.messages[:error].join(',')
        }
      else
        result_hash[i] = {
            bank_reference_number: '',
            status: '',
            amount: '',
            error: operation.messages[:error].join(',')
        }
      end
    end
  end

  def post_process
    self.file_url = create_response_csv
  end

  def success
    params[:file_url] = file_url
    Admin::BankTransfer::GetBulkStatus::FilePresenter.new(user, params, messages)
  end

  class Admin::BankTransfer::GetBulkStatus::FilePresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :file_url

    def init
      self.file_url = params[:file_url]
    end
  end

  private

  def process_row(row)
    unique_request_number = row[import_fields[:utr]].to_s

    params = {
        unique_request_number: unique_request_number
    }
  end

  def import_fields
    {
        :utr => 0,
    }
  end

  def create_response_csv
    file_name = "public/common/files/temp_files/#{DateUtils.local_date_time}-#{user.id}-result.csv".gsub(Regexp.union([' ', '-', ':', '+']), '')
    CSV.open(file_name, 'wb') do |csv|
      self.header += ['Bank Reference', 'Status', 'Amount','Errors']
      csv << header
      (2..sheet.last_row).each do |i|
        row = sheet.row(i)
        row = row.map(&:to_s)
        row += result_hash[i].values
        csv << row
      end
    end
    return file_name.gsub('public', '')
  end
end