class Policy::ApprovalWorkflows::Configs::ImportLevels < Policy::ApprovalWorkflows::Configs::Base
  attr_accessor :file, :result_hash, :policy, :sheet, :company, :level, :missing_params, :sheets

  def validate
    self.file = params[:file]
    self.result_hash = {}
    if file.present?
      self.sheets = ImportUtil.open_spreadsheet(file)
      self.header = sheets.row(1)
    end

    if result_hash.size > 0
      add_message :error, 'Sheet have some errors. Fix and retry'
    end
  end

  def process
    self.company = Company.find params[:company_id]
    self.result_hash = {}
    sheets.each_with_pagename do |name, sheet|
      self.result_hash[name] = {}
      application = get_application(name)
      provider = name
      (2..sheet.last_row).each do |i|
        row = sheet.row(i)
        self.params  =  process_row(row)
        if params[:policy_name].present?
          self.policy = get_policy(params[:policy_name], application)
        else
          self.policy = company.policies.default.first
        end
        if params[:department_code].present?
          department = company.departments.find_by department_code: params[:department_code]
          create_policy_dept_mapping(policy, department) if department.present?
        end

        if params[:location_code].present?
          location = company.locations.find_by location_code: params[:location_code]
          create_policy_location_mapping(policy, location)
        end
        row_length = row.size
        lower_index = 3
        while(lower_index < row_length)
          level_name = row[lower_index+1].to_s
          level_number = row[lower_index+2].to_i
          reviewer_id = clean_up_data row[lower_index+3].to_s
          threshold = row[lower_index+4].to_i
          if level_name.present? && level_number.present? && reviewer_id.present? && threshold.present?
            self.level = get_level(level_name, level_number, provider)
            reviewer = company.users.where(mobile_number: reviewer_id).or(company.users.where(email: reviewer_id)).first
            if reviewer
              if reviewer.policies.pluck(:id).exclude?(policy.id)
                self.policy.user_mapping.create(user: reviewer)
              end
              mapping_exist = self.level.level_reviewer_mappings.where(policy_id: policy.id, reviewer_id: reviewer.id, threshold: threshold).first
              self.level.level_reviewer_mappings.create(reviewer_id: reviewer.id, threshold: threshold) unless mapping_exist.present?
              result_hash[name][i] = 'Reviewer Mapping created'
            else
              result_hash[name][i] = 'Reviewer not found'
            end
          end
          lower_index += 4
        end
      end
    end
    add_message :success, 'Reviwer Level Imported Successfully'
  end

  def failure
    params[:file_url] = create_response_csv
    Policy::ApprovalWorkflows::Configs::ImportLevels::FilePresenter.new(user,params, messages)
  end

  def success
    params[:file_url] = create_response_csv
    Policy::ApprovalWorkflows::Configs::ImportLevels::ResultPresenter.new(user,params,messages)
  end

  class Policy::ApprovalWorkflows::Configs::ImportLevels::FilePresenter < BaseOperation::BasePresenter::FailurePresenter

    attr_accessor :file_url, :imported, :success

    def init
      self.file_url = params[:file_url]
      self.imported = false
      self.success = true
    end
  end

  class Policy::ApprovalWorkflows::Configs::ImportLevels::ResultPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :file_url, :imported
     def init
       self.imported =  true
       self.file_url = params[:file_url]
     end
  end

  private

  def process_row(row)
    policy_name = row[import_fields[:policy_name]].to_s
    department_code = row[import_fields[:department_code]].to_s
    location_code = row[import_fields[:location_code]].to_s

    params = {
        policy_name: policy_name,
        department_code: department_code,
        location_code: location_code,
        }
  end

  def import_fields
    {
        :policy_name => 0,
        :department_code => 1,
        :location_code => 2,
    }
  end

  def validate_params(row)
    self.missing_params = []
    import_fields
    import_fields.each do |k,v|
      if row[v].blank?
        self.missing_params << k.to_s.humanize
      end
    end
    missing_params
  end

  def get_policy(policy_name,application)
    policy = self.company.policies.find_by(name: policy_name, application: application)
    return policy if policy.present?
    policy = self.company.policies.create(name: policy_name, application: application)
  end

  def get_level(level_name, level_number,provider)
    level =  self.policy.levels.non_deleted.where(level_number: level_number, associated_entity_type: provider).first
    return level if level.present?
    level = self.policy.levels.create(name: level_name, level_number: level_number, associated_entity_type: provider)
  end

  def get_application(name)
    %w(ReportProvider MoneyRequestProvider TravelRequestProvider).include?(name) ? 'em' : 'vp'
  end

  def create_policy_dept_mapping(policy,department)
    return if policy.policy_department_mappings.where(department.id).first.present?
    policy.policy_department_mappings.create(department_id: department.id)
  end

  def create_policy_location_mapping(policy,location)
    return if policy.policy_location_mappings.where(location.id).first.present?
    policy.policy_location_mappings.create(location_id: location.id)
  end

  def create_response_csv
    file_name = "public/common/files/temp_files/#{DateUtils.local_date_time}-#{user.id}-result.xls".gsub(Regexp.union([' ', '-', ':', '+']), '')
    FileUtils.mkdir_p "public/common/files/temp_files" unless  Dir.exist?("public/common/files/temp_files")
    workbook  = ::WriteXLSX.new(file_name)
    sheets.each_with_pagename do |name, sheet|
      worksheet = workbook.add_worksheet(name)

      self.header.each_with_index do |item, index|
        worksheet.write( 0, index, item )
      end
      (2..sheet.last_row).each do |index|
        items = sheet.row(index)
        items << result_hash[name][index]
        items.each_with_index do |item, inner_index|
          worksheet.write((1 + index), inner_index, item)
        end
      end
    end
    workbook.close
    return file_name.gsub('public', '')
  end

  def clean_up_data(text)
    if text.is_a?(Float) || text.is_a?(Integer)
      text.to_i.to_s
    else
      text.strip
    end
  end

end