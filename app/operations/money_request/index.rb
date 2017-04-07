class MoneyRequest::Index < MoneyRequest::Base
  attr_accessor :money_requests, :role_id

  def authorized_user_types
    [:employee, :manager, :finance_manager, :admin]
  end

  def init
    self.role_id = params[:role_id]
    if self.role_id.blank? and params[:view].present?
      self.role_id = UserRole::VALUES[params[:view].to_sym]
    end
  end

  def authorize
    if self.role_id.present?
      raise_unauthorized_exception if not user.has_role?(self.role_id) and not (role_id == UserRole.id_for(:admin) and user.policy_admin?)
    elsif not user.employee?
      raise_unauthorized_exception
    end
  end

  def process
    case self.role_id
      when UserRole.id_for(:admin)
        if self.user.company_admin?
          self.money_requests = MoneyRequest.not_open.with_user(user.company.users.pluck(:id))
        elsif user.policy_admin?
          user_ids = User::Team::Index.(user, UserRole.admin_id).pluck(:id)
          policy_ids = user.admin_policies.pluck(:id)
          self.money_requests = MoneyRequest.not_open.with_user(user_ids).with_policy(policy_ids)
        end
        unless user.admin?
          messages[:error] << 'User is not an admin'
          return false
        end
      when UserRole.id_for(:manager)
        controlling_money_request_query = user.controlling_money_requests.non_owner(user.id).with_controlling_user_role_id(UserRole.id_for(:manager))
        interacted_money_requests_query= user.manager_money_requests
        sql = MoneyRequest.connection.unprepared_statement {
          "((#{controlling_money_request_query.to_sql}) UNION (#{interacted_money_requests_query.to_sql})) AS money_requests"
        }
        self.money_requests = MoneyRequest.from(sql)
      when UserRole.id_for(:finance_manager)
        controlling_money_request_query = user.controlling_money_requests.non_owner(user.id).with_controlling_user_role_id(UserRole.id_for(:finance_manager))
        interacted_money_requests_query = user.finance_money_requests
        sql = MoneyRequest.connection.unprepared_statement {
          "((#{controlling_money_request_query.to_sql}) UNION (#{interacted_money_requests_query.to_sql})) AS money_requests"
        }
        self.money_requests = MoneyRequest.from(sql)
      when UserRole.id_for(:auditor)
        # todo auditor
      else
        self.money_requests = user.money_requests.sort_for_personal
    end
    self.money_requests = self.money_requests.exclude_deleted if self.money_requests.present?
  end

  def success
    params[:money_requests] = money_requests
    MoneyRequest::Index::Presenter.new(user, params, self.messages)
  end

  class MoneyRequest::Index::Presenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :money_requests, :counts, :paginated_money_requests

    has_scope :filter_search
    has_scope :filter_status
    has_scope :filter_user_id
    has_scope :filter_date, using: [:from, :to], type: :hash
    has_scope :filter_policy

    def init
      self.money_requests = params[:money_requests]
      get_counts
      if self.money_requests.present?
        self.money_requests = apply_scopes(self.money_requests, params)
        self.paginated_money_requests = self.money_requests.paginate(page: params[:page], per_page: 30)
      end
    end

    def status_name(money_request)
      return nil if money_request.blank?
      if money_request.processing? and money_request.controlling_user?(self.user)
        'Awaiting Approval'
      else
        money_request.status_name
      end
    end

    def get_counts
      type_counts = money_requests.group(:status_id)
      self.counts = {}
      counts[:open] = (type_counts[MoneyRequestStatus.id_for(:open)] or 0)
      counts[:processing] = (type_counts[MoneyRequestStatus.id_for(:processing)] or 0)
      counts[:retracted] = (type_counts[MoneyRequestStatus.id_for(:retracted)] or 0)
      counts[:rejected] = (type_counts[MoneyRequestStatus.id_for(:rejected)] or 0)
      counts[:approved] = (type_counts[MoneyRequestStatus.id_for(:approved)] or 0)
      counts[:credited] = (type_counts[MoneyRequestStatus.id_for(:credited)] or 0)
    end


  end
end