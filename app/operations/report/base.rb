class Report::Base < BaseOperation
  attr_accessor :report, :report_id

  # todo - redefine all init methods to use report retrieval operation

  def pre_validate
    if user.blank? or params.blank?
      errors << "No user or params passed."
    end
  end

  def init
    self.report = Report::List.(user, role_id: params[:role_id]).find_by(id: params[:report_id])
    # self.report = Report.find_by(id: params[:report_id])
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

  class Report::Base::Presenter < BaseOperation::BasePresenter
    attr_accessor :report, :categories, :expenses, :manager, :status, :total, #:report_currency,
                  :dates, :comments, :buttons, :policies, :selected_policy, :violations

    def initialize(user, params={})
      super(user, params)
      self.report = params[:report]
      self.categories = user.company.categories
      self.expenses = report.expenses
      self.status = report.relative_status_name user
      self.total = report.total_amount
      self.dates = report.date_as_string
      self.comments = report.comments
      self.buttons = {}

    end

    def expenses_category_sorted

    end

    def expenses_date_sorted

    end

  end


  @expenses= []
  @categories = current_user.company.categories
  all_expenses = @report.expenses
  @categories.each do |category|
    item_expenses = all_expenses.with_category(category.id)
    if item_expenses.present?
      item_name = category.name
      item_sum = precision_value item_expenses.with_amount.sum(:value)
      @expenses << {category_name: item_name, expenses: item_expenses, category_total: item_sum}
    end
  end
  uts = UserTeamService.new(@report.user)
  manager = uts.manager(report: @report)
  if manager.blank?
    manager = uts.finance_manager(report: @report)
  end
  @manager_name = nil
  @manager_name = manager.name if manager.present?
  @status = @report.relative_status_name(current_user)
  rds = ReportDetailService.new(@report)
  @total = precision_value rds.total_amount
  @date_string = rds.date_as_string
  @comments = @report.comments.all.order(created_at: :desc)
  @views = {}
  if @admin_view
    if @report.can_take_control? and not @report.controlling_user?(current_user)
      @views[:take_control] = true
    elsif @report.processing? and @report.controlling_user?(current_user)
      @views[:review] = true
    end
  elsif @finance_view or @manager_view
    if @report.processing? and @report.controlling_user?(current_user)
      @views[:review] = true
    elsif (@report.can_unapprove?) and @report.associated_users(@report.controlling_user).include?(current_user)
      @views[:unapprove] = true
    end
    if @finance_view and @report.reimbursement_pending?
      @views[:reimburse] = true
    end
  else
    if @report.open? or @report.retracted? or @report.rejected?
      @views[:add_expenses] = true
      @views[:delete] = true
      @views[:editable] = true
      @views[:submit] = true
    elsif @report.processing?
      @views[:retract] = true
    elsif @report.reimbursed?
      @views[:reimbursement_confirm] = true
    end
  end
  # code for report policy
  @policies = @report.user.policies
  @policy = PolicyRetrievalService.for_report(@report)
  @violation_messages = @violation_service.violations(@policy, @report)


end