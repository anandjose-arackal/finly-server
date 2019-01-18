# action that retrieves the reports list of a user
# Returns a list of reports as a presenter. Can pass role_id or view in params to retrieve the respective reports
class Reports::Index < Reports::Base
  attr_accessor :reports, :role_id

  def authorized_user_types
    [:employee, :manager, :finance_manager, :admin, :auditor]
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
    #   if self.user.company_admin? || self.user.auditor?
    #     team_ids = User::Team::Index.(user, {view: params[:view]})&.pluck(:id)
    #     self.reports = Report.not_open.with_user(team_ids)
    #   elsif user.policy_admin?
    #     team_ids = User::Team::Index.(user, {view: params[:view]})&.pluck(:id)
    #     policy_ids = user.admin_policies.pluck(:id)
    #     self.reports = Report.not_open.with_user(team_ids).with_policy(policy_ids)
    #   end
    # when UserRole.id_for(:manager)
    #   team_ids = User::Team::Index.(user, {view: params[:view]})&.pluck(:id)
    #   # controlling_report_query = user.controlling_reports.non_owner(user.id).with_controlling_user_role(UserRole.manager_id).with_user(team_ids)
    #   # interacted_reports_query= user.manager_reports
    #   # sql = Report.connection.unprepared_statement {
    #   #   "((#{controlling_report_query.to_sql}) UNION (#{interacted_reports_query.to_sql})) AS reports"
    #   # }
    #   # self.reports = Report.from([Arel.sql(sql)])
    #   controlling_reports = user.controlling_reports.non_owner(user.id).with_controlling_user_role(UserRole.manager_id).with_user(team_ids).pluck(:id)
    #   interacted_reports = user.manager_reports.pluck(:id)
    #   self.reports = Report.with_id(controlling_reports + interacted_reports)
    # when UserRole.id_for(:finance_manager)
    #   team_ids = User::Team::Index.(user, {view: params[:view]})&.pluck(:id)
    #   # controlling_report_query = user.controlling_reports.non_owner(user.id).with_controlling_user_role(UserRole.finance_manager_id).with_user(team_ids)
    #   # interacted_reports_query = user.finance_reports
    #   # sql = Report.connection.unprepared_statement {
    #   #   "((#{controlling_report_query.to_sql}) UNION (#{interacted_reports_query.to_sql})) AS reports"
    #   # }
    #   # self.reports = Report.from([Arel.sql(sql)])
    #   controlling_reports = user.controlling_reports.non_owner(user.id).with_controlling_user_role(UserRole.finance_manager_id).with_user(team_ids).pluck(:id)
    #   interacted_reports = user.finance_reports.pluck(:id)
    #   self.reports = Report.with_id(controlling_reports + interacted_reports)
    # when UserRole.id_for(:auditor)
    #   # todo auditor
    # else
    #   self.reports = user.reports.sort_for_personal
    # end

    # OLD Code
    # case self.role_id
    # when UserRole.id_for(:admin), UserRole.id_for(:auditor)
    #   if self.user.company_admin? || self.user.auditor?
    #     team_ids = User::Team::Index.(user, {view: params[:view]})&.pluck(:id)
    #     self.reports = Report.not_open.with_user(team_ids)
    #   elsif user.policy_admin?
    #     team_ids = User::Team::Index.(user, {view: params[:view]})&.pluck(:id)
    #     policy_ids = user.admin_policies.pluck(:id)
    #     self.reports = Report.not_open.with_user(team_ids).with_policy(policy_ids)
    #   end
    # when UserRole.id_for(:manager)
    #   team_ids = User::Team::Index.(user, {view: params[:view]})&.pluck(:id)
    #   # controlling_report_query = user.controlling_reports.non_owner(user.id).with_controlling_user_role(UserRole.manager_id).with_user(team_ids)
    #   # interacted_reports_query= user.manager_reports
    #   # sql = Report.connection.unprepared_statement {
    #   #   "((#{controlling_report_query.to_sql}) UNION (#{interacted_reports_query.to_sql})) AS reports"
    #   # }
    #   # self.reports = Report.from([Arel.sql(sql)])
    #   controlling_reports = user.controlling_reports.non_owner(user.id).with_controlling_user_role(UserRole.manager_id).with_user(team_ids).pluck(:id)
    #   interacted_reports = user.manager_reports.pluck(:id)
    #   self.reports = Report.with_id(controlling_reports + interacted_reports)
    # when UserRole.id_for(:finance_manager)
    #   team_ids = User::Team::Index.(user, {view: params[:view]})&.pluck(:id)
    #   # controlling_report_query = user.controlling_reports.non_owner(user.id).with_controlling_user_role(UserRole.finance_manager_id).with_user(team_ids)
    #   # interacted_reports_query = user.finance_reports
    #   # sql = Report.connection.unprepared_statement {
    #   #   "((#{controlling_report_query.to_sql}) UNION (#{interacted_reports_query.to_sql})) AS reports"
    #   # }
    #   # self.reports = Report.from([Arel.sql(sql)])
    #   controlling_reports = user.controlling_reports.non_owner(user.id).with_controlling_user_role(UserRole.finance_manager_id).with_user(team_ids).pluck(:id)
    #   interacted_reports = user.finance_reports.pluck(:id)
    #   self.reports = Report.with_id(controlling_reports + interacted_reports)
    # when UserRole.id_for(:auditor)
    #   # todo auditor
    # else
    #   self.reports = user.reports.sort_for_personal
    # end

    case self.role_id
    when UserRole.id_for(:admin), UserRole.id_for(:auditor)
      if self.user.company_admin? || self.user.auditor?
        self.reports = Report.admin_associated_items(user)
      elsif user.policy_admin?
        # todo Take care of policy admins
        self.reports = Report.admin_associated_items(user)
      end
    when UserRole.id_for(:manager)
      self.reports = Report.reviewer_associated_items(user)
    when UserRole.id_for(:finance_manager)
      self.reports = Report.finance_associated_items(user)
    else
      self.reports = user.reports.sort_for_personal
    end
  end

  def post_process
    if self.reports.present?
      self.reports = self.reports.exclude_deleted.includes(:expenses, :policy, :status) rescue self.reports
    end
    if params[:ref] == '1' and params[:n_id].present?
      Event::EReport::Unset.(user, params)
    end
  end

  def success
    params[:reports] = reports
    Reports::Index::Presenter.new(user, params, messages)
  end

  class Reports::Index::Presenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :reports, :counts, :paginated_reports, :count

    has_scope :filter_search
    has_scope :filter_id
    has_scope :with_id
    # has_scope :filter_status
    has_scope :filter_user_id
    has_scope :filter_date, using: [:from, :to], type: :hash
    has_scope :filter_submitted_date, using: [:from, :to], type: :hash
    has_scope :filter_approved_date, using: [:from, :to], type: :hash
    has_scope :filter_policy
    has_scope :filter_custom_drop_down_selection, type: :array
    has_scope :filter_category
    has_scope :filter_group, type: :array

    def init
      ScopeUtils.fix_for_scoping(params, :filter_custom_drop_down_selection, :array)
      self.reports = params[:reports]

      get_counts
      return unless self.reports.present?
      self.reports = apply_scopes(self.reports, params)
      if self.reports.present?
        if params[:filter_status].present?
          self.reports = self.reports.filter_status(params[:filter_status], user.id)
        end
        if personal_view?
          self.reports = self.reports.order_by(:created_at).order_by(:controlling_user, user.id)
        else
          self.reports = self.reports.order_by(:submitted_at).order_by(:manager_controlling_user, user.id)
        end
      end
      self.count = self.reports.count
      self.paginated_reports = self.reports.paginate(page: params[:page], per_page: 30).include_details
    end

    def get_counts
      type_counts = reports.group(:report_status_id)
      self.counts = {}
      counts[:open] = (type_counts[ReportStatus.open_id] or 0)
      counts[:processing] = (type_counts[ReportStatus.processing_id] or 0)
      counts[:retracted] = (type_counts[ReportStatus.retracted_id] or 0)
      counts[:rejected] = (type_counts[ReportStatus.rejected_id] or 0)
      counts[:approved] = (type_counts[ReportStatus.approved_id] or 0)
      counts[:settled] = (type_counts[ReportStatus.settled_id] or 0)
      counts[:settlement_confirmed] = (type_counts[ReportStatus.settlement_confirmed_id] or 0)
      counts[:closed] = (type_counts[ReportStatus.closed_id] or 0)
    end

    def status_name(report)
      return nil if report.blank?
      if report.processing? and report.controlling_user?(self.user)
        'Awaiting Approval'
      else
        report.status_name
      end
    end

  end

end