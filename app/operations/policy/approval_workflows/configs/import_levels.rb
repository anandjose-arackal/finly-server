class Policy::ApprovalWorkflows::Configs::ImportLevels < Policy::ApprovalWorkflows::Configs::Base
  attr_accessor :file, :result_hash, :policy, :sheet, :company, :level, :missing_params

  def validate
    self.file = params[:file]
    self.result_hash = {}
    if file.present?
      self.sheet = ImportUtil.open_spreadsheet(file)
      self.header = sheet.row(1)
    end
    (2..sheet.last_row).each do |i|
      row = sheet.row(i)
      validate_params(row)
      result_hash[i] = "#{missing_params.to_sentence} cannot be blank" if missing_params.present?
    end
    if result_hash.size > 0
      add_message :error, 'Sheet have some errors. Fix and retry'
    end
  end

  def process
    self.company = Company.find params[:company_id]
    self.result_hash = {}
    (2..sheet.last_row).each do |i|
      row = sheet.row(i)
      self.params  =  process_row(row)
      self.policy = get_policy(params[:policy_name], params[:application])
      params[:providers].each do |provider|
        self.level = get_level(params[:level_name], params[:level_number], provider)
        reviewer = company.users.where(mobile_number: params[:reviewer_id]).or(company.users.where(email: params[:reviewer_id])).first
        if reviewer
          if reviewer.policies.pluck(:id).exclude?(policy.id)
            self.policy.user_mapping.create(user: reviewer)
          end
          self.level.level_reviewer_mappings.create(reviewer_id: reviewer.id, threshold: params[:threshold], exception: params[:exception], wo_exception: params[:wo_exception])
          result_hash[i] = 'Reviewer Mapping created'
        else
          result_hash[i] = 'Reviewer not found'
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
    level_number = row[import_fields[:level_number]].to_s.to_i
    level_name = row[import_fields[:level_name]].to_i.to_s
    threshold = row[import_fields[:threshold]].to_i
    reviewer_id = clean_up_data(row[import_fields[:reviewer]])
    exception = row[import_fields[:exception]].to_s.downcase == 'y' ? true : false
    wo_exception = row[import_fields[:wo_exception]].to_s.downcase == 'y' ? true : false
    policy_name = row[import_fields[:policy_name]].to_s
    application = row[import_fields[:application]].to_s.downcase
    providers = []
    providers << 'ReportProvider' if row[import_fields[:report]].to_s.upcase == 'Y'
    providers << 'MoneyRequestProvider' if row[import_fields[:money_request]].to_s.upcase == 'Y'
    providers << 'TravelRequestProvider' if row[import_fields[:travel_request]].to_s.upcase == 'Y'
    providers << 'BankPaymentRequestProvider' if row[import_fields[:bank_payment_request]].to_s.upcase == 'Y'
    providers << 'InvoiceProvider' if row[import_fields[:invoice]].to_s.upcase == 'Y'
    providers << 'PurchaseOrderProvider' if row[import_fields[:purchase_order]].to_s.upcase == 'Y'

    params = {
        level_number: level_number,
        level_name: level_name,
        threshold: threshold,
        reviewer_id: reviewer_id,
        exception: exception,
        wo_exception: wo_exception,
        policy_name: policy_name,
        application: application,
        providers: providers
    }
  end

  def import_fields
    {
        :level_number => 0,
        :level_name => 1,
        :reviewer => 2,
        :threshold => 3,
        :exception => 4,
        :wo_exception => 5,
        :policy_name => 6,
        :application => 7,
        :report => 8,
        :money_request => 9,
        :travel_request => 10,
        :bank_payment_request => 11,
        :invoice => 12,
        :purchase_order => 13
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

  def clean_up_data(text)
    if text.is_a?(Float) || text.is_a?(Integer)
      text.to_i.to_s
    else
      text.strip
    end
  end

end