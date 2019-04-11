class PolicyUserRoles::ForwardableUsers < PolicyUserRoles::Base
  attr_accessor :policy_user_roles, :user_roles, :document_types, :documents

  def init

    self.document_types = %w( purchase_order_provider invoice_provider )
    unless document_types.include?(params[:document_type])
      add_message :error, "Invalid Type"
    end

    unless params[:document_ids].present? || params[:document_ids].is_a?(Array)
      add_message :error, "Invalid Type"
    end

    get_documents(params[:document_type], params[:document_ids])

    policy_id = self.documents&.pluck(:policy_id)&.uniq&.compact&.first
    self.policy = user.company.policies.with_id(policy_id).first
  end

  def validate
    unless self.policy.present?
      add_message :error, 'Policy not found'
    end

    unless documents.present?
      add_message :error, "No documents found"
    end

    unless documents.pluck(:policy_id).uniq.compact.length == 1
      add_message :error, "Please select documents from one policy to see forwardable users"
    end
  end

  def process
    self.policy_user_roles = self.policy.policy_user_roles
  end

  def success
    params[:policy_user_roles] = self.policy_user_roles
    PolicyUserRoles::ForwardableUsers::IndexPresenter.new(user, params, messages)
  end

  class PolicyUserRoles::ForwardableUsers::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :policy_user_roles, :paginated_policy_user_roles
    include HasScope

    has_scope :filter_role_id
    has_scope :filter_user

    def init
      self.policy_user_roles = params[:policy_user_roles]
      self.policy_user_roles = apply_scopes(self.policy_user_roles, params)

      page = params[:page] || 1
      per_page = params[:per_page] || 10000 # hardcoded as pagination on frontend is not there

      self.paginated_policy_user_roles = self.policy_user_roles.paginate(page: page, per_page: per_page).includes_for_index
      self.user_roles = params[:user_roles]
    end
  end

  private

  def get_documents(document_type, document_ids)
    if document_type == 'purchase_order_provider'
      self.documents = Procurements::PurchaseOrders::Index.(user, params).purchase_orders.with_id(document_ids)
    elsif document_type == 'invoice_provider'
      self.documents = Procurements::Invoices::Index.(user, params).invoices.with_id(document_ids)
    else
      ## nothing
    end
  end
end