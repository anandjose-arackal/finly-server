# action that retrieves the reports list of a user

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

  def validate

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
      return Report::Index::Presenter.new(user, reports: reports)
    else
      return false
    end
  end

  class Report::Index::Presenter < BaseOperation::BasePresenter
    attr_accessor :reports

    has_scope :filter_search
    has_scope :filter_status
    has_scope :filter_user
    has_scope :filter_date, using: [:from, :to], type: :hash
    has_scope :filter_policy

    def initialize(user, params)
      self.user = user
      self.reports = params[:reports]
      self.reports = apply_scopes(self.reports, params).paginate(page: params[:page], per_page: 30) if self.reports.present?
    end

  end

end