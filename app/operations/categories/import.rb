class Categories::Import < Categories::Base
  attr_accessor :file_url, :file, :result_hash, :params, :missing_params, :sheet, :header, :categories_params, :company, :category

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
      self.categories_params = process_row(row)
      category_name = categories_params[:parent_category][:name]

      category = company.categories.with_name(category_name).first
      unless category.present?
        category = company.categories.new(categories_params[:parent_category])
        if category.save
          result_hash[i] = "Success!"
        else
        end
      end
      if categories_params[:sub_category][:name].present?
        sub_category_name = categories_params[:sub_category][:name]

        sub_category = company.categories.with_name(sub_category_name).first
        unless sub_category.present?
          categories_params[:sub_category][:ancestry] = (category.id).to_s
          sub_category = company.categories.new(categories_params[:sub_category])
          if sub_category.save
            result_hash[i] = "Success!"
          else
          end
        end
      end
    end
  end

  def post_process
    self.file_url = create_response_csv
  end

  def success
    params[:file_url] = file_url
    Categories::Import::FilePresenter.new(user, params, messages)
  end

  class Categories::Import::FilePresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :file_url

    def init
      self.file_url = params[:file_url]
    end
  end

  private

  def process_row(row)
    category_name = row[import_fields[:category_name]].to_s
    sub_category_name = row[import_fields[:sub_category_name]].to_s
    gl_code = row[import_fields[:gl_code]].to_s
    expense_management = row[import_fields[:expense_management]].to_s.upcase == 'Y' ? true : false
    vendor_payment = row[import_fields[:vendor_payment]].to_s.upcase == 'Y' ? true : false
    inward_invoice_line_items = row[import_fields[:inward_invoice_line_items]].to_s.upcase == 'Y' ? true : false

    params = {
        parent_category:{
            name: category_name,
            gl_code: (sub_category_name.blank? ? '': gl_code),
            category_code: category_code,
            expense_management: expense_management,
            vendor_payments: vendor_payment,
            inward_invoice_line_items: inward_invoice_line_items
        },
        sub_category:{
            name: sub_category_name,
            gl_code: gl_code,
            category_code: category_code,
            expense_management: expense_management,
            vendor_payments: vendor_payment,
            inward_invoice_line_items: inward_invoice_line_items
        }
    }

  end

  def import_fields
    {
        :category_name=> 0,
        :sub_category_name => 1,
        :gl_code => 2,
        :category_code => 3,
        :expense_management => 4,
        :vendor_payment => 5,
        :inward_invoice_line_items => 6
    }
  end

  def validate_params(row)
    self.missing_params = []
    if row[import_fields[:category_name]].blank?
      missing_params << "Category."
    end
    missing_params
  end

  def create_response_csv
    file = Tempfile.new("bulk_import_categories_result.csv")
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
end