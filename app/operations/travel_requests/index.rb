class TravelRequests::Index < TravelRequests::Base
  attr_accessor :travel_requests, :role_id

  def authorized_user_types
    [:employee, :manager, :finance_manager, :admin, :auditor, :travel_manager]
  end

  def init
    self.role_id = params[:role_id]
    if self.role_id.blank? and params[:view].present?
      self.role_id = UserRole::VALUES[params[:view].to_sym]
      params[:role_id] = self.role_id
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
    # case self.role_id
    # when UserRole.id_for(:admin), UserRole.id_for(:auditor)
    #   user_ids = user.company.users.pluck(:id)
    #   if self.user.company_admin? || user.auditor?
    #     self.travel_requests = TravelRequest.not_open.with_user(user_ids)
    #   elsif user.policy_admin?
    #     policy_ids = user.admin_policies.pluck(:id)
    #     self.travel_requests = TravelRequest.not_open.with_user(user_ids).with_policy(policy_ids)
    #   end
    #   unless user.admin? || user.auditor?
    #     messages[:error] << 'User is not an admin'
    #     return false
    #   end
    # when UserRole.id_for(:manager)
    #   team_ids = User::Team::Index.(user, params)&.pluck(:id)
    #   controlling_travel_request_query = user.controlling_travel_requests.non_owner(user.id).with_controlling_user_role_id(UserRole.id_for(:manager)).with_user(team_ids).pluck(:id)
    #   interacted_travel_requests_query = user.manager_travel_requests.pluck(:id)
    #   # sql = MoneyRequest.connection.unprepared_statement {
    #   #   "((#{controlling_travel_request_query.to_sql}) UNION (#{interacted_travel_requests_query.to_sql})) AS travel_requests"
    #   # }
    #   self.travel_requests = TravelRequest.with_id((controlling_travel_request_query + interacted_travel_requests_query))
    # when UserRole.id_for(:finance_manager)
    #   # Pick up trips from money requests
    #   result = MoneyRequests::Index.(user, params)
    #   if result.success?
    #     travel_requests = result.money_requests.pluck(:travel_request_id)
    #     self.travel_requests = TravelRequest.with_id(travel_requests)
    #   end
    #   # sql = MoneyRequest.connection.unprepared_statement {
    #   #   "((#{controlling_travel_request_query.to_sql}) UNION (#{interacted_travel_requests_query.to_sql})) AS travel_requests"
    #   # }
    # when UserRole.id_for(:travel_manager)
    #   team_ids = User::Team::Index.(user, params)&.pluck(:id)
    #   controlling_travel_request_query = user.controlling_travel_requests.non_owner(user.id).with_controlling_user_role_id(UserRole.id_for(:travel_manager)).with_user(team_ids).pluck(:id)
    #   interacted_travel_requests_query = user.travel_manager_travel_requests.pluck(:id)
    #   # sql = TravelRequest.connection.unprepared_statement {
    #   #   "((#{controlling_travel_request_query.to_sql}) UNION (#{interacted_travel_requests_query.to_sql})) AS travel_requests"
    #   # }
    #   self.travel_requests = TravelRequest.with_id((controlling_travel_request_query + interacted_travel_requests_query))
    # else
    #   self.travel_requests = user.travel_requests
    # end
    # self.travel_requests = self.travel_requests.exclude_deleted if self.travel_requests.present?


    case self.role_id
    when UserRole.id_for(:admin), UserRole.id_for(:auditor)
      self.travel_requests = TravelRequest.admin_associated_items(user)
    when UserRole.id_for(:manager)
      self.travel_requests = TravelRequest.reviewer_associated_items(user)
    when UserRole.id_for(:finance_manager)
      self.travel_requests = TravelRequest.finance_associated_items(user, role_id)
    when UserRole.id_for(:travel_manager)
      self.travel_requests = TravelRequest.travel_associated_items(user, role_id)
    else
      self.travel_requests = user.travel_requests
    end
    self.travel_requests = self.travel_requests.exclude_deleted if self.travel_requests.present?
  end

  def success
    params[:travel_requests] = travel_requests
    TravelRequests::Index::Presenter.new(user, params, self.messages)
  end

  class TravelRequests::Index::Presenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :travel_requests, :counts, :paginated_travel_requests, :count

    # has_scope :filter_search
    # has_scope :filter_status
    has_scope :filter_user_id
    has_scope :filter_date, using: [:from, :to], type: :hash
    # has_scope :filter_submitted_date, using: [:from, :to], type: :hash
    # has_scope :filter_approved_date, using: [:from, :to], type: :hash
    # has_scope :filter_policy
    # has_scope :filter_required_by_date
    has_scope :filter_status

    def init
      self.travel_requests = params[:travel_requests]
      unless self.travel_requests.present?
        self.paginated_travel_requests = self.travel_requests
        return
      end
      self.travel_requests = apply_scopes(self.travel_requests, params)
      if travel_requests.present?
        if personal_view?
          self.travel_requests = self.travel_requests.order_by(:created_at).order_by(:controlling_user, user.id)
        else
          self.travel_requests = self.travel_requests.order_by(:submitted_at).order_by(:manager_controlling_user, user.id)
        end
      end
      self.count = self.travel_requests.count
      self.paginated_travel_requests = self.travel_requests.paginate(page: params[:page], per_page: 30)
    end
  end

end
