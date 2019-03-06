# report retrieval requires the role id in which capacity the user is viewing the report:
# i.e. personal, manager, finance manager, or admin

require "#{Rails.root}/lib/formatter.rb"
class Reports::Base < BaseOperation
  attr_accessor :report, :report_id, :workflow_output, :violations

  def pre_validate
    if user.blank?
      messages[:error] << 'User not found'
    end
    if params.blank?
      messages[:error] << 'Error loading report'
    end

    if params[:filter_search].present?
      params[:filter_search].strip! if params[:filter_search].is_a?(String)
    end
  end

  def init
    id = (params[:id] or params[:report_id])
    self.report = Reports::Index.(user, params).reports.with_id(id).first rescue nil

    # todo - temporary fix for notifications
    # self.report = Reports::Index.(user, params).reports&.unscoped.with_id(id)&.first
    # self.report = Report.find_by(id: params[:report_id])
  end

  def authorize
    unless report
      add_message :error, 'Report not found'
      return
    end
  end

  # added here because in most cases we will be returning the report itself
  def success
    present_report
  end

  def receipt_params
    params.require(:receipt).permit(:image)
  end

  def check_for_violations
    self.violations = Reports::Violation.(user, report: self.report)
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

  def present_report
    Reports::Base::Presenter.new(self.user, {report: self.report, view: params[:view]}, messages)
  end

  class Reports::Base::Presenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :report, :categories, :expenses, :manager, :finance_manager, :status, :total, #:report_currency,
                  :dates, :comments, :actions, :policies, :selected_policy, :violations, :result, :violations_present,
                  :reimbursable_expenses_total, :non_reimbursable_expenses_total, :card_expenses_total, :budgets, :approvers,
                  :reviewal_chains, :reviewal_chain, :finance_managers, :awaiting_settlement

    def init
      self.report = params[:report]
      report.reload
      self.categories = report.user.company.categories
      self.expenses = report.expenses.includes(:amount,:receipts,:card_expense,:tds_slab,:spent_from,:category,:tds_slab,:expense_tax_type)
      self.status = report.relative_status_name user
      self.total = report.total_amount
      self.dates = report.date_as_string
      self.comments = report.comments
      self.actions = load_actions
      self.selected_policy = report.versioned_policy
      self.violations = Reports::Violation.(user, report: self.report)
      self.violations_present = has_warning? || has_blocking?
      self.finance_managers = report.document_role_users(:finance_managers)

      if Report.status_ids(:approved, :auto_approved).include?(report.status_id)
        self.awaiting_settlement = true
      else
        self.awaiting_settlement = false
      end

      # self.manager = User::Team::Approver.(report.user, report: report, type: :manager, has_violations: self.violations_present)
      # self.finance_manager = User::Team::Approver.(report.user, report: report, type: :finance_manager, has_violations: self.violations_present)
      self.reimbursable_expenses_total = reimbursable_expenses
      self.non_reimbursable_expenses_total = non_reimbursable_expenses
      self.card_expenses_total = report.total_amount(:only_card_expenses)
      self.reviewal_chain = report.get_reviewal_chain
      # op = Reports::Approvers.(report: self.report)
      # if op.success?
      #   self.approvers = op.approvers
      # else
      #   self.approvers = []
      # end

      if self.actions[:reviewal_chain_editable][:value]
        self.policies = retrieve_policies
        self.reviewal_chains = []
        params[:reviewal_document] = report

        policies.each do |policy|
          params[:policy_id] = policy.id
          params[:violations_present] = has_warning?
          chain = {
              policy_id: policy.id,
              reviewal_chain: get_reviewal_chain
          }
          self.reviewal_chains.push(chain)
        end
      else
        self.policies = Policy.where(id: self.report&.policy&.id)
      end

      # budgets_op = BudgetsProcessor::Report.(user, report: self.report)
      # self.budgets = budgets_op.budgets
      self.budgets = []

      if self.report.expenses.present?
        op = BudgetsCalculator::RelevantBudgets.(user, object: self.report)
        if op.success?
          self.budgets = op.budget_data
        end
      end
    end

    def get_reviewal_chain
      op = ::ReviewalManager::ReviewalChain.(user, params)
      if op.success?
        return op.chain
      else
        return nil
      end
    end

    def retrieve_policies
      # policies = []
      if report.user.enforce_policy_enabled?
        # policies << {id: 0, name: 'None'}
        return report.user.policies.with_application(current_app).non_default.non_deleted
      end
      report.user.policies.with_application(current_app).non_deleted
    end

    def status_name(report)
      return nil if report.blank?
      if report.processing? and report.controlling_user?(self.user)
        'Awaiting Approval'
      elsif report.auto_approved?
        'Auto Approved'
      else
        report.status_name
      end
    end

    def reimbursable_expenses
      report.reimbursable_expenses
    end

    def non_reimbursable_expenses
      report.non_reimbursable_expenses
    end

    def has_custom_fields?
      self.expenses&.each do |expense|
        if expense.has_custom_fields?
          return true
        end
      end
      false
    end

    def expenses_category_sorted
      categorized_expenses = []
      self.categories.roots.each do |category|
        cat_ids = [category.id]
        if category.children.present?
          cat_ids += category.children.pluck(:id)
        end
        item_expenses = self.report.expenses.with_category(cat_ids)
        if item_expenses.present?
          item_name = category.name
          item_sum = precision_value item_expenses.with_amount.sum(report.base_currency_code)
          categorized_expenses << {section_name: item_name, expenses: item_expenses, section_total: item_sum}
        end
      end
      categorized_expenses
    end

    def expenses_date_sorted
      date_expenses = []
      dates = self.expenses.map(&:date).uniq
      dates.each do |date|
        item_expenses = self.report.expenses.with_date(date)
        if item_expenses.present?
          item_name = DateUtils.date_formatted date
          item_sum = precision_value item_expenses.with_amount.sum(report.base_currency_code)
          date_expenses << {section_name: item_name, expenses: item_expenses, section_total: item_sum}
        end
      end
      date_expenses
    end

    def load_actions
      actions = {
          reviewal_chain_editable: {value: false}
      }
      # Editable Receipts

      # if self.report.controlling_user?(user) && (self.report.open? || self.report.processing? || self.report.retracted? || self.report.rejected?)
      #   actions[:editable_receipts] = {url: Rails.application.routes.url_helpers.report_toggle_receipt_hardcopy_path(report_id: report.id, view: params[:view])} 
      # end

      # if admin_view?
      #   if self.report.can_take_control? and not self.report.controlling_user?(user) #and not self.report.user.id == user.id
      #     actions[:take_control] = {url: Rails.application.routes.url_helpers.report_take_control_path(report_id: report.id, view: params[:view])}
      #   elsif self.report.processing? and self.report.controlling_user?(user)
      #     actions[:approve] = {url: Rails.application.routes.url_helpers.report_approve_path(report_id: report.id, view: params[:view])}
      #     actions[:reject] = {url: Rails.application.routes.url_helpers.report_reject_path(report_id: report.id, view: params[:view])}
      #     actions[:editable_receipts] = {url: Rails.application.routes.url_helpers.report_toggle_receipt_hardcopy_path(report_id: report.id, view: params[:view])}
      #     actions[:manager_editable] = {value: true}
      #   end
      # elsif finance_view? or manager_view?
      #   if self.report.processing? and self.report.controlling_user?(user)
      #     actions[:approve] = {url: Rails.application.routes.url_helpers.report_approve_path(report_id: report.id, view: params[:view])}
      #     actions[:reject] = {url: Rails.application.routes.url_helpers.report_reject_path(report_id: report.id, view: params[:view])}
      #     actions[:editable_receipts] = {url: Rails.application.routes.url_helpers.report_toggle_receipt_hardcopy_path(report_id: report.id, view: params[:view])}
      #     actions[:manager_editable] = {value: true}
      #   elsif (self.report.can_unapprove?) and Reports::AssociatedUsers.(self.user, report: self.report, user_before: self.report.controlling_user).include?(user)
      #     actions[:unapprove] = {url: Rails.application.routes.url_helpers.report_unapprove_path(report_id: report.id, view: params[:view])}
      #   end
      # else
      #   if self.report.open? or self.report.retracted? or self.report.rejected?
      #     actions[:add_expenses] = {url: Rails.application.routes.url_helpers.report_add_expenses_path(report_id: report.id, view: params[:view])}
      #     actions[:delete] = {url: Rails.application.routes.url_helpers.report_path(id: report.id, view: params[:view])}
      #     actions[:editable] = {value: true}
      #     actions[:submit] = {url: Rails.application.routes.url_helpers.report_submit_path(report_id: report.id, view: params[:view])}
      #     actions[:editable_receipts] = {url: Rails.application.routes.url_helpers.report_toggle_receipt_hardcopy_path(report_id: report.id, view: params[:view])}
      #   elsif self.report.can_retract?
      #     actions[:retract] = {url: Rails.application.routes.url_helpers.report_retract_path(report_id: report.id, view: params[:view])}
      #   elsif self.report.settled?
      #     actions[:settlement_confirm] = {url: Rails.application.routes.url_helpers.report_settlement_confirm_path(report_id: report.id, view: params[:view])}
      #   end
      # end

      # New Actions
      if admin_view?
        if self.report.can_take_control? and not self.report.get_reviewers.include?(user)
          actions[:take_control] = {url: Rails.application.routes.url_helpers.report_take_control_path(report_id: report.id, view: params[:view])}
          # actions[:return_control] = {url: Rails.application.routes.url_helpers.report_return_control_path(report_id: report.id, view: params[:view])}
        elsif self.report.processing? and self.report.get_reviewers.include?(user)
          actions[:approve] = {url: Rails.application.routes.url_helpers.report_approve_path(report_id: report.id, view: params[:view])}
          actions[:reject] = {url: Rails.application.routes.url_helpers.report_reject_path(report_id: report.id, view: params[:view])}
          actions[:editable_receipts] = {url: Rails.application.routes.url_helpers.report_toggle_receipt_hardcopy_path(report_id: report.id, view: params[:view])}
          actions[:manager_editable] = {value: true}
        end
      elsif manager_view?
        if self.report.processing? && self.report.get_reviewers.include?(user)
          actions[:approve] = {url: Rails.application.routes.url_helpers.report_approve_path(report_id: report.id, view: params[:view])}
          actions[:reject] = {url: Rails.application.routes.url_helpers.report_reject_path(report_id: report.id, view: params[:view])}
          actions[:editable_receipts] = {url: Rails.application.routes.url_helpers.report_toggle_receipt_hardcopy_path(report_id: report.id, view: params[:view])}
          actions[:manager_editable] = {value: true}
        elsif (self.report.can_unapprove?) && self.report.action_users(:unapprove).include?(user)
          actions[:unapprove] = {url: Rails.application.routes.url_helpers.report_unapprove_path(report_id: report.id, view: params[:view])}
        end
      elsif finance_view?
      else
        if self.report.open? or self.report.retracted? or self.report.rejected?
          actions[:reviewal_chain_editable] = {value: true}
          actions[:add_expenses] = {url: Rails.application.routes.url_helpers.report_add_expenses_path(report_id: report.id, view: params[:view])}
          actions[:delete] = {url: Rails.application.routes.url_helpers.report_path(id: report.id, view: params[:view])}
          actions[:editable] = {value: true}
          actions[:submit] = {url: Rails.application.routes.url_helpers.report_submit_path(report_id: report.id, view: params[:view])}
          actions[:editable_receipts] = {url: Rails.application.routes.url_helpers.report_toggle_receipt_hardcopy_path(report_id: report.id, view: params[:view])}
        elsif self.report.can_retract?
          actions[:retract] = {url: Rails.application.routes.url_helpers.report_retract_path(report_id: report.id, view: params[:view])}
        elsif self.report.settled?
          actions[:settlement_confirm] = {url: Rails.application.routes.url_helpers.report_settlement_confirm_path(report_id: report.id, view: params[:view])}
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
        warning_messages.concat violation['budget_warning'] if violation['budget_warning'].present?
      end
      if warning_messages.size > 0
        warning_messages.uniq!
        Formatter.remove_blanks warning_messages
      end
      warning_messages
    end

    def cash_pockets
      list = []
      report.user.user_pockets.non_bank_card_transfer_pockets.include_details.each do |pocket|
        hash = {}
        if pocket.cash_pocket?
          adapter = AccountManager::CashPockets::CashPocketsAdapter.new(pocket)
          hash[:balance] = adapter&.balance(display_balance: true)
          hash[:display_balance] = true
        else
          hash[:balance] = 0
          hash[:display_balance] = false
        end
        hash[:name] = pocket.name
        hash[:id] = pocket.id

        currency = pocket.base_currency
        hash[:base_currency] = {
            symbol: currency&.symbol,
            country_code: currency&.country_code,
            id: currency&.id
        }
        list << hash
      end
      list
    end
  end
end
