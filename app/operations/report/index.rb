# action that retrieves the reports list of a user
# Returns a list of reports as a presenter. Can pass role_id or view in params to retrieve the respective reports
class Report::Index < Report::Base
  attr_accessor :reports, :role_id

  def authorized_user_types
    [:employee, :manager, :finance_manager, :admin]
  end

  def self.call(user, params)
    self.new(user, params).run
  end

  def init
    self.role_id = params[:role_id]
    if self.role_id.blank? and params[:view].present?
      self.role_id = UserRole::VALUES[params[:view].to_sym]
    end
  end

  def authorize
    if self.role_id.present?
      raise_unauthorized_exception unless user.has_role?(self.role_id)
    elsif not user.employee?
      raise_unauthorized_exception
    end
  end

  def process
    case self.role_id
      when UserRole.admin_id
        if self.user.company_admin?
          self.reports = Report.not_open.with_user(user.company.users.pluck(:id))
        elsif user.policy_admin?
          user_ids = User::Team::Show.(user, UserRole.admin_id).pluck(:id)
          policy_ids = user.admin_policies.pluck(:id)
          self.reports = Report.not_open.with_user(user_ids).with_policy(policy_ids)
        end
        unless user.admin?
          errors << 'User is not an admin'
          return false
        end
      when UserRole.manager_id
        controlling_report_query = user.controlling_reports.non_owner(user.id)
        interacted_reports_query= user.manager_reports
        sql = Report.connection.unprepared_statement {
          "((#{controlling_report_query.to_sql}) UNION (#{interacted_reports_query.to_sql})) AS reports"
        }
        self.reports = Report.from(sql)
      when UserRole.finance_manager_id
        controlling_report_query = user.controlling_reports.non_owner(user.id)
        interacted_reports_query = user.finance_reports
        sql = Report.connection.unprepared_statement {
          "((#{controlling_report_query.to_sql}) UNION (#{interacted_reports_query.to_sql})) AS reports"
        }
        self.reports = Report.from(sql)
      when UserRole.auditor_id
        # todo auditor
      else
        self.reports = user.reports
    end
  end

  def retrieve
    if is_success?
      params[:reports] = reports
      Report::Index::Presenter.new(user, params)
    else
      false
    end
  end

  class Report::Index::Presenter < BaseOperation::BasePresenter
    attr_accessor :reports, :counts

    has_scope :filter_search
    has_scope :filter_status
    has_scope :filter_user
    has_scope :filter_date, using: [:from, :to], type: :hash
    has_scope :filter_policy

    def initialize(user, params)
      self.user = user
      self.reports = params[:reports]
      get_counts
      self.reports = apply_scopes(self.reports, params).paginate(page: params[:page], per_page: 30) if self.reports.present?
    end

    def get_counts
      type_counts = reports.group(:report_status_id)
      self.counts = {}
      counts[:open] = (type_counts[ReportStatus.open_id] or 0)
      counts[:processing] = (type_counts[ReportStatus.processing_id] or 0)
      counts[:retracted] = (type_counts[ReportStatus.retracted_id] or 0)
      counts[:rejected] = (type_counts[ReportStatus.rejected_id] or 0)
      counts[:approved] = (type_counts[ReportStatus.approved_id] or 0)
      counts[:reimbursed] = (type_counts[ReportStatus.reimbursed_id] or 0)
      counts[:reimbursement_confirmed] = (type_counts[ReportStatus.reimbursement_confirmed_id] or 0)
      counts[:closed] = (type_counts[ReportStatus.closed_id] or 0)
    end


  end

end