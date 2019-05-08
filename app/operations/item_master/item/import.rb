class ItemMaster::Item::Import < ItemMaster::Item::Base
  attr_accessor :file_url, :file, :result_hash, :params, :missing_params, :sheet, :header, :item_params, :company,

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
      self.item_params = process_row(row)
      item = company.items.new(item_params)
      if item.save
        result_hash[i] = "Success!"
      else
       result_hash[i] =item.errors.full_messages
      end
    end
  end

  def post_process
    self.file_url = create_response_csv
  end

  def success
    params[:file_url] = file_url
    ItemMaster::Item::Import::FilePresenter.new(user, params, messages)
  end

  class ItemMaster::Item::Import::FilePresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :file_url

    def init
      self.file_url = params[:file_url]
    end
  end

  private

  def process_row(row)
    description = row[import_fields[:description]].to_s
    category_id = company.categories.where(name: row[import_fields[:category]].to_s).first&.id
    hsn_sac = row[import_fields[:hsn_sac]].blank? ? nil : row[import_fields[:hsn_sac]].to_i
    item_code = row[import_fields[:item_code]].to_s
    discount = row[import_fields[:discount]].to_f&.round(2)
    rate = row[import_fields[:rate]].to_f&.round(2)


    params ={
      description: description,
      category_id: category_id,
      hsn_sac: hsn_sac,
      item_code: item_code,
      discount: discount,
      rate: rate
    }
  end

  def import_fields
    {
       :description => 0,
       :category => 1,
       :hsn_sac => 2,
       :item_code => 3,
       :discount => 4,
       :rate => 5
    }
  end


  def validate_params(row)
    self.missing_params = []
    if row[import_fields[name]].blank?
      missing_params << "Item Name"
    end
    if row[import_fields[category]].present?
       category_id = company.categories.where(name: row[import_fields[:category]].to_s).first&.id
       missing_params << "Category Not Found"
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