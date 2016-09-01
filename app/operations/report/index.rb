# action that retrieves the reports list of a user

class Report::Index < Report::Base
  attr_accessor :reports


  def authorized_user_types
    [:employee, :manager, :finance_manager, :admin]
  end

  def self.call(user, params)
    self.new(user, params).run
  end

  def init

  end

  def validate

  end

  def authorize

  end

  def process
    case params[:role_id]
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
      when UserRole.employee_id
        self.reports = user.reports
      else
        return nil
    end
  end

  def retrieve
    if is_success?
      return Report::Index::Presenter.new(user, reports: reports)
    else
      return false
    end
  end

  class Report::Index::Presenter < BaseOperation::BasePresenter
    attr_accessor :reports, :counts

    def initialize(user, params)
      self.user = user
      self.reports = params[:reports]
      get_counts
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