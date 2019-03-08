class Policy::ApprovalWorkflows::DownloadLevelReviewerMappings < Policy::ApprovalWorkflows::Base

  attr_accessor :mappings, :result, :policy, :sheets, :headers, :content

  def authorized_user_types
    [:company_admin]
  end

  def init
    id = params[:id] || params[:policy_id]
    self.policy = user.company.policies.find_by(id: id)
    self.sheets = []
    self.headers = []
    self.content = []
  end

  def validate
    if self.policy.blank?
      add_message :error, "Policy not found"
    end
  end

  def process
    users = self.policy.users
    providers = ["ReportProvider", "MoneyRequestProvider", "TravelRequestProvider", "PurchaseOrderProvider", "InvoiceProvider", "BankPaymentRequestProvider"]
    provider_mappings = {}
    providers.each do |provider|
      # for each set of iterations we will have an array of arrays,
      # where each line is one user's mappings
      document_mappings = []
      headers = ["User Details"]
      users.each do |user|
        mapping_row = []
        mapping_row << "#{user.name}"
        levels = self.policy.levels.non_deleted.where(associated_entity_type: provider)
        headers += levels.pluck(:name)
        levels.each do |level|
          lurms = level.level_user_reviewer_mappings.where(user_id: user.id)
          if lurms.empty?
            lurms = level.level_reviewer_mappings.non_deleted
          end
          reviewer_ids = lurms.pluck(:reviewer_id)
          reviewer_names = []
          reviewer_ids.each do |reviewer_id|
            reviewer_names << "#{User.find_by(id: reviewer_id)&.name}"
          end
          mapping_row << reviewer_names.to_sentence
        end
        if ["ReportProvider", "MoneyRequestProvider"].include?(provider)
          finance_ids = policy.policy_user_roles.with_role_id(UserRole.id_for(:finance_manager)).pluck(:user_id)
        elsif ["TravelRequestProvider"].include?(provider)
          finance_ids = policy.policy_user_roles.with_role_id(UserRole.id_for(:travel_manager)).pluck(:user_id)
        elsif ["InvoiceProvider", "PurchaseOrderProvider", "BankPaymentRequestProvider"].include?(provider)
          finance_ids = policy.policy_user_roles.with_role_id(UserRole.id_for(:creditor)).pluck(:user_id)
        else
          finance_ids = []
        end

        finance_names = []
        finance_ids.each do |finance_id|
          finance_names << User.find_by(id: finance_id)&.name
        end
        mapping_row << finance_names.to_sentence

        document_mappings << mapping_row
      end
      provider_mappings[provider] = {
          contents: document_mappings,
          headers: headers
      }
    end

    # now set this in the various sheets that are present
    provider_mappings.each do |provider, contents|
      sheet_details = {
          item_headers: contents[:headers],
          item_contents: contents[:contents],
          name: provider.gsub("Provider", "")
      }
      self.sheets << sheet_details
    end
  end

  def post_process

  end

  def success
    self.response = Exporter.new(user, {spreadsheet: {headers: self.headers, contents: self.content, sheets: self.sheets}}, messages)
  end

  private

end