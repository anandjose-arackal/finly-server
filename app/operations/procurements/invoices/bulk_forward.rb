class Procurements::Invoices::BulkForward < Procurements::Invoices::Base
  attr_accessor :invoices, :policy, :forwarded_to_user, :result

  def init
    self.result = {
      success: [],
      error: []
    }
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
    self.invoices.each do |invoice|
      data_success = {}
      data_error = {}
      workflow_input = {
        document: invoice,
        aasm_event: 'forward',
        forwarded_to_user: forwarded_to_user
      }

      op = WorkflowManager::Base.(user, workflow_input)
      if op.success?
        data_success[:invoice_id] = invoice&.invoice_id
        data_success[:invoice_number] = invoice&.invoice_number
        data_success[:sub_department] = invoice&.sub_department&.name
        data_success[:department] = invoice&.department&.name
        data_success[:user] = invoice&.created_by&.name
        data_success[:amount] = invoice&.net_amount&.value
        self.result[:success].push(data_success)
      else
        data_error[:messages] = op.messages[:error]
        data_error[:invoice_id] = invoice&.invoice_id
        data_error[:invoice_number] = invoice&.invoice_number
        data_error[:sub_department] = invoice&.sub_department&.name
        data_error[:department] = invoice&.department&.name
        data_error[:user] = invoice&.created_by&.name
        data_error[:amount] = invoice&.net_amount&.value
        self.result[:error].push(data_error)
      end
    end
  end

  def post_process
    if self.result[:forwarded] != 0
      add_message :success, "Successfully forwarded #{self.result[:success].length} invoice to #{self.forwarded_to_user.name}"
    end

    if self.result[:not_forwarded] != 0
      add_message :success, "Couldn't forward #{self.result[:error].length} invoice"
    end

    Event::EInvoice::BulkForward.(user, result: result, forwarded_to_user: forwarded_to_user)
  end
end