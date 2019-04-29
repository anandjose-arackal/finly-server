class TdsSlabs::Import < TdsSlabs::Base
  attr_accessor :file_url, :file, :result_hash, :params, :missing_params, :sheet, :header, :tds_params, :company,

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters. please try again"
    end
  end

  def user_model
   [User, AdminUser]
  end

  def init
    self.company = Company.find_by_id params[:company_id].to_i
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
      self.tds_params = process_row(row)
      tds_rate = company.tds_slabs.new(tds_params)
      if tds_rate.save
        result_hash[i] = "Success!"
      else
      end
    end
  end

  def post_process
    self.file_url = create_response_csv
  end

  def success
    params[:file_url] = file_url
    TdsSlabs::Import::FilePresenter.new(user, params, messages)
  end

  class TdsSlabs::Import::FilePresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :file_url

    def init
      self.file_url = params[:file_url]
    end
  end

  private

  def process_row(row)
    name = row[import_fields[:name]].to_s
    tds = row[import_fields[:tds]].to_s.delete('%').to_f

    params = {
      name: name,
      tds: tds
    }

  end

  def import_fields
    {
       :name => 0,
       :tds => 1
    }
  end

  def validate_params(row)
    self.missing_params = []
    if row[import_fields[name]].blank?
      missing_params << "TDS Name"
    end
    if row[import_fields[tds]].blank?
        missing_params << "TDS Rate"
    end
    missing_params
  end

  def create_response_csv
    file_name = "public/common/files/temp_files/#{DateUtils.local_date_time}-#{user.id}-result.csv".gsub(Regexp.union([' ', '-', ':', '+']), '')
    CSV.open(file_name, 'wb') do |csv|
      self.header << 'Result'
      csv << header
      (2..sheet.last_row).each do |i|
        row = sheet.row(i)
        row = row.map(&:to_s)
        row << result_hash[i]
        csv << row
      end
    end
    return file_name.gsub('public', '')
  end
end