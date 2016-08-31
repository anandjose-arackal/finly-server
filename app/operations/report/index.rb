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
      return Report::Index::Presenter.(user, reports: reports)
    else
      return false
    end
  end

  class Report::Index::Presenter < BaseOperation::BasePresenter
    attr_accessor :reports

    def initialize
      self.user = user
      self.reports = reports
    end

  end

end