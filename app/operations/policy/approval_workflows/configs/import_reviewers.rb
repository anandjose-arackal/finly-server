class Policy::ApprovalWorkflows::Configs::ImportReviewers < Policy::ApprovalWorkflows::Configs::Base
  attr_accessor :file, :result_hash, :policy, :sheet, :company, :level, :missing_params, :sheets

  def validate
    self.file = params[:file]
    self.result_hash = {}
    if file.present?
      self.sheets = ImportUtil.open_spreadsheet(file)
      self.header = sheets.row(1)
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
        if params[:user_email].present?
          entity_user_id = clean_up_data params[:user_email]
          entity_user = company.users.where(mobile_number: entity_user_id).or(company.users.where(email: entity_user_id)).first
        end
        unless entity_user.present?
          result_hash[name][i] = 'User not found'
          next
        end
        row_length = row.size
        lower_index = 1
        while(lower_index < row_length)
          level_name = row[lower_index+1].to_s
          level_number = row[lower_index+2].to_i
          reviewer_id = clean_up_data row[lower_index+3].to_s
          threshold = row[lower_index+4].to_i
          if level_name.present? && level_number.present? && threshold.present?
            self.level = get_level(level_name, level_number, provider)
            reviewer = company.users.where(mobile_number: reviewer_id).or(company.users.where(email: reviewer_id)).first
              mapping_exist = self.level.level_user_reviewer_mappings.where(policy_id: policy.id, reviewer_id: reviewer&.id, threshold: threshold, user_id: entity_user.id).first
              self.level.level_user_reviewer_mappings.create(reviewer_id: reviewer&.id, policy_id: policy.id,user_id: entity_user.id, threshold: threshold) unless mapping_exist.present?
              result_hash[name][i] = 'Reviewer Mapping created'
          end
          lower_index += 4
        end
      end
    end
    add_message :success, 'Reviwer Level Imported Successfully'
  end

  def failure
    params[:file_url] = create_response_csv
    Policy::ApprovalWorkflows::Configs::ImportReviewers::FilePresenter.new(user,params, messages)
  end

  def success
    params[:file_url] = create_response_csv
    Policy::ApprovalWorkflows::Configs::ImportReviewers::ResultPresenter.new(user,params,messages)
  end

  class Policy::ApprovalWorkflows::Configs::ImportReviewers::FilePresenter < BaseOperation::BasePresenter::FailurePresenter

    attr_accessor :file_url, :imported, :success

    def init
      self.file_url = params[:file_url]
      self.imported = false
      self.success = true
    end
  end

  class Policy::ApprovalWorkflows::Configs::ImportReviewers::ResultPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :file_url, :imported
    def init
      self.imported =  true
      self.file_url = params[:file_url]
    end
  end

  private

  def process_row(row)
    policy_name = row[import_fields[:policy_name]].to_s
    user_email = row[import_fields[:user_email]].to_s

    params = {
        policy_name: policy_name,
        user_email: user_email
    }
  end

  def import_fields
    {
        :policy_name => 0,
        :user_email => 1
    }
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
    file = Tempfile.new("bulk_import_lurm_result.xls")
    workbook  = ::WriteXLSX.new(file)
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