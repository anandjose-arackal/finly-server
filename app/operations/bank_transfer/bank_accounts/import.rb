class BankTransfer::BankAccounts::Import < BankTransfer::BankAccounts::Base
  attr_accessor :file_url, :file, :result_hash, :params, :missing_params, :sheet, :header, :bank_account_params, :company,

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters. please try again"
    end
  end

  def init
    self.company = user.company
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
    if company.nil?
      add_message :error, "Company not found"
    end
  end

  def process
    (2..sheet.last_row).each do |i|
      row = sheet.row(i)
      self.bank_account_params = process_row(row)
     user_entity = company.users.where(mobile_number: bank_account_params[:user_id]).or(company.users.where(email: bank_account_params[:user_id])).first
     unless user_entity.present?
       result_hash[i] = "User Not Found"
       next
     end
     bank_account_params[:default_account] = user_entity.bank_accounts.count > 0 ? true : false
     bank_account = user_entity.bank_accounts.new(name: bank_account_params[:name],account_number: bank_account_params[:account_number], ifsc: bank_account_params[:ifsc],default_account: bank_account_params[:default_account])
     if bank_account.save
       result_hash[i] = "Success!"
     else
       result_hash[i] = bank_account.errors.full_messages
     end

    end
  end

  def post_process
    self.file_url = create_response_csv
  end

  def success
    params[:file_url] = file_url
    BankTransfer::BankAccounts::FilePresenter.new(user, params, messages)
  end

  class BankTransfer::BankAccounts::FilePresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :file_url

    def init
      self.file_url = params[:file_url]
    end
  end

  private

  def process_row(row)
    name = row[import_fields[:name]].to_s
    user_id = clean_up_data row[import_fields[:user_id]]
    account_number = clean_up_data row[import_fields[:account_number]]
    ifsc = row[import_fields[:ifsc]]
    p user_id
    params = {
      name: name,
      user_id: user_id,
      account_number: account_number,
      ifsc: ifsc
    }

  end

  def import_fields
    {
       :name => 0,
       :user_id => 1,
       :account_number => 2,
       :ifsc => 3
    }
  end

  def create_response_csv
    file = Tempfile.new("bulk_import_bank_accounts_result.csv")
        CSV.open(file.path, 'wb') do |csv|
          self.header << 'Result'
          csv << header
          (2..sheet.last_row).each do |i|
            row = sheet.row(i)
            row = row.map(&:to_s)
            row << result_hash[i]
            csv << row
          end
        end
    temp_file = TemporaryFile.create file: file, expires_on: (DateTime.now.beginning_of_day + 1.day)
    return temp_file.file.url
  end

  def clean_up_data(text)
    if text.is_a?(Float) || text.is_a?(Integer)
      text.to_i.to_s
    else
      text.strip
    end
  end
end