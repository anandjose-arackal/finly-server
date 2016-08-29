class Report::Base < BaseOperation

  attr_accessor :report, :report_id

  # todo - redefine all init methods to use report retrieval operation

  def pre_validate
    if user.blank? or params.blank?
      errors << "No user or params passed."
    end
  end


  def init
    self.report = Report.find_by(id: params[:report_id])
  end


  def authorize
    unless report
      raise_unauthorized_exception
    end
  end

  # added here because in most cases we will be returning the report itself
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

  def receipt_params
    params.require(:receipt).permit(:image)
  end

end