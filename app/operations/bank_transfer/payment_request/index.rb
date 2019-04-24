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

    if user.vendor_payments_admin?
      admin_restricted_status_ids = [BankPaymentRequestStatus.id_for(:open)]
      self.payment_requests = ::BankPaymentRequest.role_based_admin_associated_items(user, UserRole.id_for(:admin), {admin_restricted_status_ids: admin_restricted_status_ids}).not_open.or(user.bank_payment_requests)
      return
    end

    unless user.policy_user_roles.pluck(:user_role_id).uniq.blank?
      self.payment_requests = ::BankPaymentRequest.associated_items(user, ::BankPaymentRequest.roles) || ::BankPaymentRequest.none
    else
      self.payment_requests = ::BankPaymentRequest.none
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

    attr_accessor :payment_requests, :paginated_payment_requests

    has_scope :filter_status
    has_scope :filter_date, using: [:from, :to], type: :hash
    has_scope :filter_custom_drop_down_selection, type: :array
    has_scope :filter_policy_id
    has_scope :filter_user_id
    has_scope :filter_scheduled_date, using: [:from, :to], type: :hash
    has_scope :filter_controlling_user
    has_scope :filter_payment_ids
    has_scope :filter_vendor_id
    has_scope :filter_month
    has_scope :filter_year

    def init
      self.payment_requests = params[:payment_requests]
      self.payment_requests = apply_scopes(payment_requests)
      per_page = params[:per_page] || 30
      page = params[:page] || 1
      # if self.payment_requests.present?
      #   if personal_view?
      #     self.payment_requests = self.payment_requests.order_by(:created_at)#.order_by(:controlling_user, user.id)
      #   else
      #     self.payment_requests = self.payment_requests.order_by(:submitted_at)#.order_by(:manager_controlling_user, user.id)
      #   end
      # end
      # if self.payment_requests.present?
      self.payment_requests = self.payment_requests.order_by(:submitted_at)
      # end
      self.paginated_payment_requests = self.payment_requests.paginate(page: page, per_page: per_page) rescue ::BankPaymentRequest.none
      self.paginated_payment_requests = self.paginated_payment_requests.include_for_index
    end

    def status_count
      pt_status_ids = BankPaymentRequest.status_ids(:open, :processing, :retracted, :rejected, :approved, :credited)
      po_status_ids = [PaymentOrderStatus.id_for(:failed), PaymentOrderStatus.id_for(:scheduled), PaymentOrderStatus.id_for(:pending)]

      payment_tickets_counts = self.payment_requests.where(status_id: pt_status_ids)&.group(:status_id)&.count

      result = {
        all: 0,
        draft: 0,
        processing: 0,
        approved: 0,
        credited: 0,
        failed: 0,
        scheduled: 0,
        pending: 0,
        awaiting_approval: 0
      }

      BankPaymentRequestStatus.all.map do |status|
        if payment_tickets_counts&.keys&.include?(status.id)
          case status.id
          when BankPaymentRequestStatus.id_for(:open), BankPaymentRequestStatus.id_for(:retracted), BankPaymentRequestStatus.id_for(:rejected)
            result[:draft] += payment_tickets_counts[status.id]
          when BankPaymentRequestStatus.id_for(:processing)
            result[:processing] += payment_tickets_counts[status.id]
          when BankPaymentRequestStatus.id_for(:approved)
            result[:approved] += payment_tickets_counts[status.id]
          when BankPaymentRequestStatus.id_for(:credited)
            result[:credited] += payment_tickets_counts[status.id]
          end
        end
      end

      result[:awaiting_approval] = self.payment_requests.awaiting_action_items(user).count

      payment_order_counts = self.payment_requests&.joins(:payment_order)&.where('payment_orders.payment_order_status_id': po_status_ids)&.group(:payment_order_status_id)&.count
      PaymentOrderStatus.all.map do |status|
        if payment_order_counts&.keys&.include? status.id
          case status.id
          when PaymentOrderStatus.id_for(:failed)
            result[:failed] += payment_order_counts[status.id]
          when PaymentOrderStatus.id_for(:scheduled)
            result[:scheduled] += payment_order_counts[status.id]
          when PaymentOrderStatus.id_for(:pending)
            result[:pending] += payment_order_counts[status.id]
          end
        end
      end
      result
    end

  #   def status_count
  #     # grab all relevant ids whose filter count needs to be sent
  #     bpr_ids = [ BankPaymentRequestStatus.id_for(:open), BankPaymentRequestStatus.id_for(:processing),
  #                 BankPaymentRequestStatus.id_for(:retracted), BankPaymentRequestStatus.id_for(:rejected),
  #                 BankPaymentRequestStatus.id_for(:approved), BankPaymentRequestStatus.id_for(:credited) ]
  #     po_ids = [ PaymentOrderStatus.id_for(:failed), PaymentOrderStatus.id_for(:scheduled), PaymentOrderStatus.id_for(:pending)]



  #     awaiting_ids = self.payment_requests&.awaiting_action_items(RequestStore.store[:current_user]&.id)&.pluck(:id)
  #     awaiting_approval = self.payment_requests&.with_id(awaiting_ids)&.count

  #     # get raw count and then replace the id with its status name
  #     bpr = self.payment_requests&.where(status_id: bpr_ids)&.group(:status_id)&.count
  #     bpr_name = {}
  #     BankPaymentRequestStatus.all.each {|ps| if bpr&.keys&.include? ps.id then bpr_name[ps.name] = bpr[ps.id] end}

  #     # get raw count and then replace the id with its status name
  #     po = self.payment_requests&.joins(:payment_order)&.where('payment_orders.payment_order_status_id': po_ids)&.group(:payment_order_status_id)&.count      
  #     po_name = {}
  #     PaymentOrderStatus.all.each {|ps| if po&.keys&.include? ps.id then po_name[ps.name] = po[ps.id] end}
  #     po_name[:awaiting_approval] = awaiting_approval || 0

  #     # merge
  #     bpr_name.reverse_merge(po_name)
  #   end
  end

end