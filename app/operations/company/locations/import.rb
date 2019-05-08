class Company::Locations::Import < Company::Locations::Base
  attr_accessor :file_url, :file, :result_hash, :params, :missing_params, :sheet, :header, :location_params, :company

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
      self.location_params = process_row(row)

      unless validate_params(row)
        result_hash[i] = "#{missing_params.to_sentence} cannot be blank"
        next
      end

      location = company.locations.new(location_params)
      if location.save
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
    Company::Locations::Import::FilePresenter.new(user, params, messages)
  end

  class Company::Locations::Import::FilePresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :file_url

    def init
      self.file_url = params[:file_url]
    end
  end

  private

  def process_row(row)
  p row
    name = row[import_fields[:name]].to_s
    state_name = row[import_fields[:state]].to_s
    state_id = State.where("name LIKE ?", state_name)&.first&.id
    address_1 = row[import_fields[:address_1]].to_s
    gstin = row[import_fields[:gstin]].to_s
    location_code = row[import_fields[:location_code]].to_s
    nature_of_office = row[import_fields[:nature_of_office]].to_s

    params = {

        name: name,
        state_id: state_id,
        address_1: address_1,
        gstin: gstin,
        location_code: location_code,
        nature_of_office: nature_of_office
    }
  end

  def import_fields
    {
        :name=> 0,
        :address_1 => 1,
        :city => 2,
        :state => 3,
        :gstin => 4,
        :location_code => 5,
        :nature_of_office => 6
    }
  end

  def validate_params(row)
    self.missing_params = []
    if row[import_fields[:name]].blank?
      missing_params << "Location."
    end
    missing_params
  end

  def create_response_csv
    file_name = "public/common/files/temp_files/#{DateUtils.local_date_time}-#{user.id}-result.csv".gsub(Regexp.union([' ', '-', ':', '+']), '')
    FileUtils.mkdir_p "public/common/files/temp_files" unless  Dir.exist?("public/common/files/temp_files")
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