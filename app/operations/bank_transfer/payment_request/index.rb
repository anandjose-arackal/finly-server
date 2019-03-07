# this operation should return the list of payment requests that a particular user
# has access to from the index screen - based on the approval flow logic
# essentially, payment orders that one owns, and payment orders that one has access to
class BankTransfer::PaymentRequest::Index < BankTransfer::PaymentRequest::Base

  attr_accessor :role_id, :payment_requests

  def pre_validate
    super
  end

  def init
    # self.role_id = params[:role_id]
    # if self.role_id.blank? and params[:view].present?
    #   self.role_id = UserRole::VALUES[params[:view].to_sym]
    # end
  end

  def authorize
    # if self.role_id.blank?
    #   unless user.payment_initiator?
    #     add_message :error, "You are not authorized for this operation"
    #   end
    # end
  end

  def process
    # case self.role_id
    # when UserRole.id_for(:admin), UserRole.id_for(:auditor)
    #   if self.user.vendor_payments_admin? || self.user.auditor?
    #     team_ids = user.company.users.pluck(:id)
    #     self.payment_requests = BankPaymentRequest.not_open.with_user(team_ids)
    #   end
    # when UserRole.id_for(:manager)
    #   team_ids = User::Team::Index.(user, role_id: UserRole.id_for(:manager))&.pluck(:id)
    #   controlling_payment_requests_query = user.controlling_payment_requests.non_owner(user.id).with_controlling_user_role(UserRole.manager_id).with_user(team_ids)
    #   interacted_payment_requests_query = user.manager_payment_requests
    #   sql = BankPaymentRequest.connection.unprepared_statement {
    #     "((#{controlling_payment_requests_query.to_sql}) UNION (#{interacted_payment_requests_query.to_sql})) AS bank_payment_requests"
    #   }
    #   self.payment_requests = BankPaymentRequest.from([Arel.sql(sql)])
    # when UserRole.id_for(:finance_manager)
    #   team_ids = User::Team::Index.(user, role_id: UserRole.id_for(:finance_manager))&.pluck(:id)
    #   controlling_payment_requests_query = user.controlling_payment_requests.non_owner(user.id).with_controlling_user_role(UserRole.finance_manager_id).with_user(team_ids)
    #   interacted_payment_requests_query = user.finance_payment_requests
    #   sql = BankPaymentRequest.connection.unprepared_statement {
    #     "((#{controlling_payment_requests_query.to_sql}) UNION (#{interacted_payment_requests_query.to_sql})) AS bank_payment_requests"
    #   }
    #   self.payment_requests = BankPaymentRequest.from([Arel.sql(sql)])
    # else
    #   self.payment_requests = user.bank_payment_requests
    # end
    # ********* Workflow manager changes start ************************
    # role_ids = user.role_mapping.vendor_payments.pluck(:user_role_id)
    # payment_request_ids = []
    # if role_ids.include?(UserRole.id_for(:admin))
    #   payment_request_ids += BankPaymentRequest.admin_associated_items(user).map(&:id)
    # end
    # if role_ids.include?(UserRole.id_for(:reviewer))
    #   payment_request_ids += BankPaymentRequest.reviewer_associated_items(user).map(&:id)
    # end
    # if role_ids.include?(UserRole.id_for(:creditor))
    #   payment_request_ids += BankPaymentRequest.creditor_associated_items(user).map(&:id)
    # end
    # if role_ids.include?(UserRole.id_for(:initiator))
    #   payment_request_ids += user.bank_payment_requests.map(&:id)
    # end

    # role_ids = user.role_mapping.vendor_payments.pluck(:user_role_id)
    # payment_request_ids = []
    # if role_ids.include?(UserRole.id_for(:admin)) || role_ids.include?(UserRole.id_for(:auditor))
    #   self.payment_requests = BankPaymentRequest.admin_associated_items(user).not_open.or(user.bank_payment_requests)
    # elsif role_ids.include?(UserRole.id_for(:reviewer)) || role_ids.include?(UserRole.id_for(:creditor))
    #   if role_ids.include?(UserRole.id_for(:reviewer))
    #     self.payment_requests = BankPaymentRequest.reviewer_associated_items(user).or(user.bank_payment_requests)
    #   end
    #   if role_ids.include?(UserRole.id_for(:creditor))
    #     if self.payment_requests.present?
    #       self.payment_requests = self.payment_requests.or(BankPaymentRequest.creditor_associated_items(user).or(user.bank_payment_requests))
    #     else
    #       self.payment_requests = BankPaymentRequest.creditor_associated_items(user).or(user.bank_payment_requests)
    #     end
    #   end
    # else
    #   self.payment_requests = user.bank_payment_requests
    # end

    # self.payment_requests = BankPaymentRequest.role_based_associated_items(user)
    
    # ********* Workflow manager changes end ************************

    # ****************** Policy User Role based index start ****************
    unless user.policy_user_roles.pluck(:user_role_id).uniq.blank?
      self.payment_requests = BankPaymentRequest.associated_items(user)
    else
      self.payment_requests = user.bank_payment_requests
    end


    # ******************Policy User Role based index end ******************* 
    

    # self.payment_requests = BankPaymentRequest.with_id(payment_request_ids)

    # case self.role_id
    # when UserRole.id_for(:admin), UserRole.id_for(:auditor)
    #   if self.user.vendor_payments_admin? || self.user.auditor?
    #     # team_ids = user.company.users.pluck(:id)
    #     # self.payment_requests = BankPaymentRequest.not_open.with_user(team_ids)
    #     self.payment_requests = BankPaymentRequest.admin_associated_items(user)
    #   end
    # when UserRole.id_for(:manager)
    #   # team_ids = User::Team::Index.(user, role_id: UserRole.id_for(:manager))&.pluck(:id)
    #   # controlling_payment_requests_query = user.controlling_payment_requests.non_owner(user.id).with_controlling_user_role(UserRole.manager_id).with_user(team_ids)
    #   # interacted_payment_requests_query = user.manager_payment_requests
    #   # sql = BankPaymentRequest.connection.unprepared_statement {
    #   #   "((#{controlling_payment_requests_query.to_sql}) UNION (#{interacted_payment_requests_query.to_sql})) AS bank_payment_requests"
    #   # }
    #   # self.payment_requests = BankPaymentRequest.from([Arel.sql(sql)])
    #   self.payment_requests = BankPaymentRequest.reviewer_associated_items(user)
    # when UserRole.id_for(:creditor)
    #   self.payment_requests = BankPaymentRequest.creditor_associated_items(user)
    #   # team_ids = User::Team::Index.(user, role_id: UserRole.id_for(:finance_manager))&.pluck(:id)
    #   # controlling_payment_requests_query = user.controlling_payment_requests.non_owner(user.id).with_controlling_user_role(UserRole.finance_manager_id).with_user(team_ids)
    #   # interacted_payment_requests_query = user.finance_payment_requests
    #   # sql = BankPaymentRequest.connection.unprepared_statement {
    #   #   "((#{controlling_payment_requests_query.to_sql}) UNION (#{interacted_payment_requests_query.to_sql})) AS bank_payment_requests"
    #   # }
    #   # self.payment_requests = BankPaymentRequest.from([Arel.sql(sql)])
    # else
    #   self.payment_requests = user.bank_payment_requests
    # end

  end

  def success
    params[:payment_requests] = self.payment_requests
    BankTransfer::PaymentRequest::Index::PaymentPresenter.new(user, params, messages)
  end

  class BankTransfer::PaymentRequest::Index::PaymentPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :payment_requests, :paginated_requests

    has_scope :filter_status_id
    has_scope :filter_date, using: [:from, :to], type: :hash
    has_scope :filter_custom_drop_down_selection, type: :array
    has_scope :filter_policy_id
    has_scope :filter_user_id
    has_scope :filter_scheduled_date, using: [:from, :to], type: :hash
    # has_scope :filter_controlling_user
    has_scope :filter_payment_ids
    has_scope :filter_vendor_id

    def init
      self.payment_requests = params[:payment_requests]
      self.payment_requests = apply_scopes(payment_requests)
      per_page = params[:per_page] || 30
      if self.payment_requests.present?
        if personal_view?
          self.payment_requests = self.payment_requests.order_by(:created_at)#.order_by(:controlling_user, user.id)
        else
          self.payment_requests = self.payment_requests.order_by(:submitted_at)#.order_by(:manager_controlling_user, user.id)
        end
      end
      self.paginated_requests = self.payment_requests.paginate(page: params[:page], per_page: per_page)
    end
  end

end