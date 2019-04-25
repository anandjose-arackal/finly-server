class Company::Departments::Import < Company::Departments::Base
  attr_accessor :file_url, :file, :result_hash, :params, :missing_params, :sheet, :header, :company, :department, :sub_department, :department_params

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
      self.department_params = process_row(row)

      unless validate_params(row)
        result_hash[i] = "#{missing_params.to_sentence} cannot be blank"
        next
      end

      self.department = company.departments.with_name(department_params[:department_name]).first
        unless department.present?
          self.department = company.departments.new(name: department_params[:department_name])
          if department.save
            result_hash[i] = "Success!"
          else
            result_hash[i] = "Department not created"
          end
        end
        if department_params[:sub_department_name].present?
         self.sub_department = company.departments.with_name(department_params[:sub_department_name]).first
          unless sub_department.present?
            self.sub_department = company.departments.new(name: department_params[:sub_department_name], parent_id: department.id)
            if sub_department.save
                result_hash[i] = "Success!"
              else
                result_hash[i] = "Sub Department not created"
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
    Company::Departments::Import::FilePresenter.new(user, params, messages)
  end

  class Company::Departments::Import::FilePresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :file_url

    def init
      self.file_url = params[:file_url]
    end
  end

  private

  def process_row(row)
    department_name = row[import_fields[:department]].to_s
    sub_department_name = row[import_fields[:sub_department]].to_s


    params = {
        department_name: department_name,
        sub_department_name: sub_department_name
    }
  end

  def import_fields
    {
        :department=> 0,
        :sub_department => 1,
    }
  end

  def validate_params(row)
    self.missing_params = []
    if row[import_fields[:department]].blank?
      missing_params << "Department."
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