class Vendors::Import < Vendors::Base
  attr_accessor :file_url, :file, :result_hash, :params, :missing_params, :sheet, :header, :vendor_params, :company,

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
      self.vendor_params = process_row(row)
      vendor = company.yes_bank_vendors.new(vendor_params["vendor"])
      if vendor.save
         result_hash[i] = "Success!"
      else
        result_hash[i] =vendor.errors.full_messages
      end
    end
  end

  def post_process
    self.file_url = create_response_csv
  end

  def success
    params[:file_url] = file_url
    Vendors::Import::FilePresenter.new(user, params, messages)
  end

  class Vendors::Import::FilePresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :file_url

    def init
      self.file_url = params[:file_url]
    end
  end

  private

  def process_row(row)
    name = row[import_fields[:name]].to_s
    mobile_number = row[import_fields[:mobile_number]].to_s
    email = row[import_fields[:email]].to_s
    business_name = row[import_fields[:business_name]].to_s
    pan = row[import_fields[:pan]].to_s
    state_code_id = nil
    state_code_id = State.where("name LIKE ?", "%"+row[import_fields[:state]].to_s+"%").first&.id if !row[import_fields[:business_name]].to_s.blank?
    description = row[import_fields[:description]].to_s
    address = row[import_fields[:address]].to_s
    created_by_id = self.company.users.only_admins&.first&.id
    account_number = row[import_fields[:account_number]].to_s
    ifsc = row[import_fields[:ifsc]].to_s
    gstin = row[import_fields[:gstin]].to_s
    location = row[import_fields[:location]].to_s

    params =  {"vendor"=>{"name"=> row[import_fields[:name]].to_s,
                          "authorized"=>"1",
                          "mobile_number"=> mobile_number,
                          "email"=> email ,
                          "currency_id"=>"1",
                          "vendor_id"=> "",
                          "business_name"=> business_name,
                          "pan"=> pan,
                          "state_code_id"=> state_code_id,
                          "description"=> description,
                          "address"=> address,
                          "status_id"=> 6,
                          "created_by_id"=> created_by_id,
                          }}

    bank_params={"bank_accounts_attributes" =>[{"name"=>"#{business_name}'s Account",
                                   "account_number"=>account_number,
                                   "ifsc"=> ifsc,
                                   "default_account"=>"1"}]}
    gstin_locations={"gstin_locations_attributes" => [{"location" =>location,
                                             "gstin"=>gstin,
                                             "state_id"=> state_code_id}]}

    if account_number.present?
       params["vendor"]["bank_accounts_attributes"] = bank_params["bank_accounts_attributes"]
    end

    if gstin.present?
       params["vendor"]["gstin_locations_attributes"] = gstin_locations["gstin_locations_attributes"]
    end
    params
  end

  def import_fields
    {
       :name => 0,
       :mobile_number => 1,
       :email => 2,
       :business_name => 3,
       :pan => 4,
       :state => 5,
       :description => 6,
       :address => 7,
       :gstin => 8,
       :location => 9,
       :account_number => 10,
       :ifsc => 11
    }
  end


  def validate_params(row)
    self.missing_params = []
    if row[import_fields[business_name]].blank?
      missing_params << "Vendor Name"
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