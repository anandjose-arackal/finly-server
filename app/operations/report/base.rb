# report retrieval requires the role id in which capacity the user is viewing the report:
# i.e. personal, manager, finance manager, or admin

class Report::Base < BaseOperation
  attr_accessor :report, :report_id

  def pre_validate
    if user.blank?
      messages[:error] << 'User not found'
    end
    if params.blank?
      messages[:error] << 'Error loading report'
    end
  end

  def init
    id = (params[:id] or params[:report_id])
    self.report = Report::Index.(user, params).reports.with_id(id).first rescue nil
    # self.report = Report.find_by(id: params[:report_id])
  end


  def authorize
    unless report
      raise_unauthorized_exception
    end
  end

  # added here because in most cases we will be returning the report itself
  def success
    present_report
  end

  def receipt_params
    params.require(:receipt).permit(:image)
  end

  def present_report
    Report::Base::Presenter.new(self.user, {report: self.report, view: params[:view]}, messages)
  end

  class Report::Base::Presenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :report, :categories, :expenses, :manager, :finance_manager, :status, :total, #:report_currency,
                  :dates, :comments, :actions, :policies, :selected_policy, :violations, :result

    def init
      self.report = params[:report]
      self.categories = user.company.categories
      self.expenses = report.expenses
      self.status = report.relative_status_name user
      self.total = report.total_amount
      self.dates = report.date_as_string
      self.comments = report.comments
      self.actions = load_actions
      self.policies = report.user.policies
      self.selected_policy = report.versioned_policy
      self.manager = User::Team::Approver.(report.user, type: :manager)
      self.finance_manager = User::Team::Approver.(report.user, type: :finance_manager)
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
          actions[:take_control] = {url: Rails.application.routes.url_helpers.report_take_control_path(report_id: report.id, view: params[:view])}
        elsif self.report.processing? and self.report.controlling_user?(user)
          actions[:approve] = {url: Rails.application.routes.url_helpers.report_approve_path(report_id: report.id, view: params[:view])}
          actions[:reject] = {url: Rails.application.routes.url_helpers.report_reject_path(report_id: report.id, view: params[:view])}
        end
      elsif finance_view? or manager_view?
        if self.report.processing? and self.report.controlling_user?(user)
          actions[:approve] = {url: Rails.application.routes.url_helpers.report_approve_path(report_id: report.id, view: params[:view])}
          actions[:reject] = {url: Rails.application.routes.url_helpers.report_reject_path(report_id: report.id, view: params[:view])}
        elsif (self.report.can_unapprove?) and self.report.associated_users(self.report.controlling_user).include?(user)
          actions[:unapprove] = {url: Rails.application.routes.url_helpers.report_unapprove_path(report_id: report.id, view: params[:view])}
        end
      else
        if self.report.open? or self.report.retracted? or self.report.rejected?
          actions[:add_expenses] = {url: Rails.application.routes.url_helpers.report_add_expenses_path(report_id: report.id, view: params[:view])}
          actions[:delete] = {url: Rails.application.routes.url_helpers.report_path(id: report.id, view: params[:view])}
          actions[:editable] = {value: true}
          actions[:submit] = {url: Rails.application.routes.url_helpers.report_submit_path(report_id: report.id, view: params[:view])}
        elsif self.report.processing?
          actions[:retract] = {url: Rails.application.routes.url_helpers.report_retract_path(report_id: report.id, view: params[:view])}
        elsif self.report.reimbursed?
          actions[:reimbursement_confirm] = {url: Rails.application.routes.url_helpers.report_reimbursement_confirm_path(report_id: report.id, view: params[:view])}
        end
      end
      actions
    end

    def has_blocking?
      return false unless self.violations.present?
      self.violations.each do |key, violation|
        if violation[:expense_blocking].present? or violation[:budget_blocking].present? or
            violation['expense_blocking'].present? or violation['budget_blocking'].present?
          return true
        end
      end
      false
    end

    def has_warning?
      return false unless self.violations.present?
      self.violations.each do |key, violation|
        if violation[:expense_warning].present? or violation[:budget_warning].present? or
            violation['expense_warning'].present? or violation['budget_warning'].present?
          return true
        end
      end
      false
    end

    def blocking_array
      blocking_messages = []
      self.violations.each do |key, violation|
        blocking_messages.concat violation[:expense_blocking] if violation[:expense_blocking].present?
        blocking_messages.concat violation[:budget_blocking] if violation[:budget_blocking].present?
        blocking_messages.concat violation['expense_blocking'] if violation['expense_blocking'].present?
        blocking_messages.concat violation['budget_blocking'] if violation['budget_blocking'].present?
      end
      if blocking_messages.size > 0
        blocking_messages.uniq!
        Formatter.remove_blanks blocking_messages
      end
      blocking_messages
    end

    def warning_array
      warning_messages = []
      self.violations.each do |key, violation|
        warning_messages.concat violation[:expense_warning] if violation[:expense_warning].present?
        warning_messages.concat violation[:budget_warning] if violation[:budget_warning].present?
        warning_messages.concat violation['expense_warning'] if violation['expense_warning'].present?
        warning_messages.concat violation['expense_warning'] if violation['expense_warning'].present?
      end
      if warning_messages.size > 0
        warning_messages.uniq!
        Formatter.remove_blanks warning_messages
      end
      warning_messages
    end
  end
end