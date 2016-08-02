class ReportPolicy < ApplicationPolicy

  def initialize(user, report)
    @user = user
    @report = report
    @report_service = ReportService.new(user: @user, report: @report)
  end

  def create?
    # only personal view allowed
    check_personal_view
  end

  def index?
    true
  end

  def show?
    # if it's personal view, check if user owns the report
    if check_personal_view
      if @user.id == @report.user.id
        return true
      else
        return false
      end
    end
    true
  end

  def destroy?
    return unless check_personal_view
    # only owner can delete a report
    unless @report.user.id == @user.id
      return false
    end
    true
  end

  # only the owner can update a report
  def update?
    return unless check_personal_view
    # only owner can edit a report
    unless @report.user.id == @user.id
      return false
    end
    true
  end

  # only the owner can add expenses, and the report must be in the open or retracted state
  def add_expenses?
    return unless check_personal_view
    # only owner can delete a report
    unless @report.user.id == @user.id
      return false
    end
    unless @report.open? || @report.retracted?
      return false
    end
    true
  end

  def remove_expenses?
    # i.e same permissions as add_expenses
    add_expenses?
  end

  def comment?
    true
  end

  def assign_policy?
    # i.e same permissions as add_expenses
    add_expenses?
  end

  def submit?
    return unless check_personal_view
    # only owner can submit
    unless @report.user.id == @user.id
      return false
    end

  end

  def retract?
    return unless check_personal_view
    # only owner can retract
    unless @report.user.id == @user.id
      return false
    end
  end

  def approve?
    return false unless check_manager_view
    # check if report is approvable
    unless @report.processing?
      return false
    end
    # check if the current user can approve this report
    unless @report.controlling_user_id == @user.id
      return false
    end
    true
  end

  def reimburse?
    return false unless check_finance_view
    # ensure report is approved before reimbursement
    unless @report.approved?
      return false
    end
    true
  end

  def reject?
    return false unless check_manager_view
    # check if report is approvable
    unless @report.processing?
      return false
    end
    # check if the current user can reject this report
    unless @report.controlling_user_id == @user.id
      return false
    end
    true
  end

  def reimbursement_confirm?
    return unless check_personal_view
    # only owner can confirm reimbursement
    unless @report.user.id == @user.id
      return false
    end
  end

  def unapprove?
    true
  end

  def take_control?
    true
  end

  # todo - all the flow actions in report
end