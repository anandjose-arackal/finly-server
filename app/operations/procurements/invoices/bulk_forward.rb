class Procurements::Invoices::BulkForward < Procurements::Invoices::Base
  attr_accessor :invoices, :policy, :forwarded_to_user, :result

  def init
    self.result = {}
    unless params[:document_ids].present? || params[:document_ids].is_a?(Array)
      add_message :error, "Invalid Type"
    end

    # self.invoices = Procurements::Invoices::Index.(user, params).invoices.with_id(params[:document_ids])
    self.invoices = BankTransfer::InwardInvoices::Index.(user, params).invoices.with_id(params[:document_ids])

    if self.invoices&.pluck(:policy_id)&.uniq&.compact&.length > 1
      add_message :error, "Please select invoices from a single policy"
    end

    policy_id = self.invoices&.pluck(:policy_id)&.uniq&.compact&.first
    self.policy = user.company.policies.with_id(policy_id).first

    unless self.policy.present?
      add_message :error, 'Policy not found'
      return
    end

    forwardable_user_ids = self.policy.policy_user_roles.with_role_id(UserRole.id_for(:invoice_reviewer)).pluck(:user_id)

    unless forwardable_user_ids.include?(params[:forward_to_id].to_i)
      add_message :error, "Invalid User"
    end

    self.forwarded_to_user = user.company.users.with_id(params[:forward_to_id].to_i).first
  end

  def validate
    unless self.invoices.present?
      add_message :error, 'Invoices not found'
      return
    end

    unless self.forwarded_to_user.present?
      add_message :error, "User not found"
    end
  end

  def process
    forwarded = 0
    not_forwarded = 0
    self.invoices.each do |invoice|
      workflow_output = {
        document: invoice,
        aasm_event: 'forward',
        violation_present: false,
        forwarded_to_user: forwarded_to_user
      }

      op = WorkflowManager::Base.(user, workflow_output)
      if op.success?
        forwarded += 1
      else
        not_forwarded += 1
      end
    end

    self.result[:forwarded] = forwarded
    self.result[:not_forwarded] = not_forwarded
  end

  def post_process
    if self.result[:forwarded] != 0
      add_message :success, "Successfully forwarded #{self.result[:forwarded]} invoice to #{self.forwarded_to_user.name}"
    end

    if self.result[:not_forwarded] != 0
      add_message :success, "Couldn't forward #{self.result[:non_forwarded]} invoice"
    end

  end
end