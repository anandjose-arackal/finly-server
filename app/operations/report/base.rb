class Report::Base < BaseOperation

  attr_accessor :report, :report_id


  # added here because in most cases we will be returing the report itself
  def retrieve
    if is_success?
      return report
    else
      return false
    end
  end

  def user_role_for_report
    if user.id == report.user.id
      return UserRole.employee_id
    elsif user.manager? and User::Team::IsApprover.new(user, {report: self.report, type: :manager}).run
      return UserRole.manager_id
    elsif user.finance_manager? and User::Team::IsApprover.new(user, {report: self.report, type: :finance_manager}).run
      return UserRole.finance_manager_id
    end
  end


end