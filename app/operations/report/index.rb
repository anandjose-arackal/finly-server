# action that retrieves the reports list of a user
# Returns a list of reports as a presenter. Can pass role_id or view in params to retrieve the respective reports
class Report::Index < Report::Base
  attr_accessor :reports, :role_id

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
          team_ids = User::Team::Index.(user, UserRole.id_for(:admin))&.pluck(:id)
          self.reports = Report.not_open.with_user(team_ids)
        elsif user.policy_admin?
          team_ids = User::Team::Index.(user, UserRole.id_for(:admin))&.pluck(:id)
          policy_ids = user.admin_policies.pluck(:id)
          self.reports = Report.not_open.with_user(team_ids).with_policy(policy_ids)
        end
        unless user.admin?
          messages[:error] << 'User is not an admin'
          return false
        end
      when UserRole.id_for(:manager)
        team_ids = User::Team::Index.(user, UserRole.id_for(:manager))&.pluck(:id)
        controlling_report_query = user.controlling_reports.non_owner(user.id).with_controlling_user_role(UserRole.manager_id).with_user(team_ids)
        interacted_reports_query= user.manager_reports
        sql = Report.connection.unprepared_statement {
          "((#{controlling_report_query.to_sql}) UNION (#{interacted_reports_query.to_sql})) AS reports"
        }
        self.reports = Report.from([Arel.sql(sql)])
      when UserRole.id_for(:finance_manager)
        team_ids = User::Team::Index.(user, UserRole.id_for(:finance_manager))&.pluck(:id)
        controlling_report_query = user.controlling_reports.non_owner(user.id).with_controlling_user_role(UserRole.finance_manager_id).with_user(team_ids)
        interacted_reports_query = user.finance_reports
        sql = Report.connection.unprepared_statement {
          "((#{controlling_report_query.to_sql}) UNION (#{interacted_reports_query.to_sql})) AS reports"
        }
        self.reports = Report.from([Arel.sql(sql)])
      when UserRole.id_for(:auditor)
        # todo auditor
      else
        self.reports = user.reports.sort_for_personal
    end
  end

  def post_process
    if self.reports.present?
      self.reports = self.reports.exclude_deleted.includes(:expenses, :policy, :status) rescue self.reports
    end
  end

  def success
    params[:reports] = reports
    Report::Index::Presenter.new(user, params, messages)
  end

  class Report::Index::Presenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :reports, :counts, :paginated_reports

    has_scope :filter_search
    has_scope :filter_status
    has_scope :filter_user_id
    has_scope :filter_date, using: [:from, :to], type: :hash
    has_scope :filter_policy

    def init
      self.reports = params[:reports]
      get_counts
      if self.reports.present?
        self.reports = apply_scopes(self.reports, params)
        self.paginated_reports = self.reports.paginate(page: params[:page], per_page: 30)
      end
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