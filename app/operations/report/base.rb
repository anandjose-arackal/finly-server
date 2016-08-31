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
      present_report
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

  def present_report
    Report::Base::Presenter.new(self.user, report: self.report)
  end

  class Report::Base::Presenter < BaseOperation::BasePresenter
    attr_accessor :report, :categories, :expenses, :manager, :status, :total, #:report_currency,
                  :dates, :comments, :actions, :policies, :selected_policy, :violations

    def initialize(user, params={})
      super(user, params)
      self.report = params[:report]
      self.categories = user.company.categories
      self.expenses = report.expenses
      self.status = report.relative_status_name user
      self.total = report.total_amount
      self.dates = report.date_as_string
      self.comments = report.comments
      self.actions = load_actions
      self.policies = report.user.policies
      self.selected_policy = report.policy
      self.manager = User::Team::Approver.(report.user, type: :manager)
      self.finance_manager =User::Team::Approver.(report.user, type: :finance_manager)
      self.violations = Report::Violation.(user, report: self.report)
    end

    def expenses_category_sorted
      categorized_expenses = []
      self.categories.each do |category|
        item_expenses = self.expenses.with_category(category.id)
        if item_expenses.present?
          item_name = category.name
          item_sum = precision_value item_expenses.with_amount.sum(:value)
          categorized_expenses << {section_name: item_name, expenses: item_expenses, section_total: item_sum}
        end
      end
      categorized_expenses
    end

    def expenses_date_sorted
      date_expenses = []
      dates = self.expenses.map(&:date).uniq
      dates.each do |date|
        item_expenses = self.expenses.with_date(date)
        if item_expenses.present?
          item_name = date
          item_sum = precision_value item_expenses.with_amount.sum(:value)
          date_expenses << {section_name: item_name, expenses: item_expenses, section_total: item_sum}
        end
      end
      date_expenses
    end

    def load_actions
      actions = {}
      if admin_view?
        if self.report.can_take_control? and not self.report.controlling_user?(user)
          actions[:take_control] = {url: report_take_control_path(report_id: report.id, view: params[:view])}
        elsif self.report.processing? and self.report.controlling_user?(user)
          actions[:approve] = {url: report_approve_path(report_id: report.id, view: params[:view])}
          actions[:reject] = {url: report_reject_path(report_id: report.id, view: params[:view])}
        end
      elsif finance_view? or manager_view?
        if self.report.processing? and self.report.controlling_user?(user)
          actions[:approve] = {url: report_approve_path(report_id: report.id, view: params[:view])}
          actions[:reject] = {url: report_reject_path(report_id: report.id, view: params[:view])}
        elsif (self.report.can_unapprove?) and self.report.associated_users(self.report.controlling_user).include?(user)
          actions[:unapprove] = {url: report_path(report_id: report.id, view: params[:view])}
        end
      else
        if self.report.open? or self.report.retracted? or self.report.rejected?
          actions[:add_expenses] = {url: report_add_expenses_path(report_id: report.id, view: params[:view])}
          actions[:delete] = {url: report_path(id: report.id, view: params[:view])}
          actions[:editable] = {value: true}
          actions[:submit] = {url: report_submit_path(report_id: report.id, view: params[:view])}
        elsif self.report.processing?
          actions[:retract] = {url: report_retract_path(report_id: report.id, view: params[:view])}
        elsif self.report.reimbursed?
          actions[:reimbursement_confirm] = {url: report_reimbursement_confirm(report_id: report.id, view: params[:view])}
        end
      end
      actions
    end
  end
end