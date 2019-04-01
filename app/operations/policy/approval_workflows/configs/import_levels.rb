class Policy::ApprovalWorkflows::Configs::ImportLevels < Policy::ApprovalWorkflows::Configs::Base
  attr_accessor :file, :result_hash, :policy, :sheet, :company, :level

  def validate
    2..sheet.last_row.each do |i|
      row = sheet[i]
      validate_params(row)
      result_hash[i] = "#{missing_params.to_sentence} cannot be blank"
    end
    if result_hash.size > 0
      add_message :error, 'Sheet have some errors. Fix and retry'
    end
  end

  def process
    self.company = Company.includes
    2..sheet.last_row.each do |i|
      row = sheet[1]
      self.params  =  process_row(row)
      self.policy = get_policy(params[:policy_name], params[:application])
      params[:providers].each do |provider|
        self.level = get_level(params[:level_name], params[:level_number], provider)
        reviewer = company.users.where(mobile_number: params[:reviewer]).or(company.users.where(email: params[:reviewer])).first
        if reviewer
          self.level.level_reviewer_mappings.create(reviewer_id: reviewer.id, threshold: params[:threshold], exception: params[:exception], wo_exception: params[:wo_exception])
        end
      end
    end
  end

  def failure

  end

  class Policy::ApprovalWorkflows::Configs::ImportLevels::FilePresenter < BaseOperation::BasePresenter::FailurePresenter

    attr_accessor :file_url

    def init
      self.file_url = params[:file_url]
    end
  end

  private

  def process_row(row)
    level_number = row[import_fields[:level_number]].to_s.to_i
    level_name = row[import_fields[:level_name]].to_i.to_s
    threshold = row[import_fields[:threshold]].to_i.to_s
    reviewer_id = row[import_fields[:reviewer]].to_i.to_s
    exception = row[import_fields[:exception]].to_s.downcase == y ? true : false
    wo_exception = row[import_fields[:wo_exception]].to_s.downcase == y ? true : false
    policy_name = row[import_fields[:policy_name]].to_s
    application = row[import_fields[:application]].to_s
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
        :threshold => 2,
        :exception => 3,
        :wo_exception => 4,
        :reviewer => 5,
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
    import_fields.each do |k,v|
      if row[v].blank?
        self.missing_params << v.to_s.humanize
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
    level =  self.policy.levels.non_deleted.where(level_number: 1, associated_entity_type: provider).first
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

end