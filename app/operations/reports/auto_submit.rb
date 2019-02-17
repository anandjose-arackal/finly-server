class Reports::AutoSubmit < Reports::Base
  attr_accessor :processing_expenses, :auto_submit_config, :selected_user, :report, :has_violations

  def pre_validate
    if params[:user].blank? and params[:user_id].blank? and params[:id].blank?
      add_message :error, 'User not found'
    end
  end

  def init
    self.selected_user = params[:user]
    if selected_user.blank?
      id = (params[:user_id] and params[:id])
      self.selected_user = User::Team::Index.(user, params).with_id(id).first rescue nil if id.present?
    end
    return unless self.selected_user.present?
    self.auto_submit_config = selected_user.auto_submit_config
    if auto_submit_config.enabled
      self.processing_expenses = Expense::Index.(selected_user, filter_status_id: ExpenseStatus.id_for(:unreported)).expenses
      self.processing_expenses = self.processing_expenses.only_card_expenses if self.processing_expenses.present? and auto_submit_config.limit_to_card_expenses
    end
  end

  def validate
    if selected_user.blank?
      add_message :error, 'User not found'
      return
    end
    unless auto_submit_config.present? and auto_submit_config.enabled
      add_message :error, 'Auto submit has not been enabled for the user'
    end
  end

  def authorize

  end

  def process
    return if self.processing_expenses.blank?
    create_report
    return if has_errors?
    validate_report
    return if has_errors?
    submit_report
  end

  def post_process
    return if self.report.blank?

    Event::EReport::Submit.(selected_user, report: report)

    add_message :success, 'Report Submitted'
  end

  def success
    params[:report] = self.report
    BaseOperation::BasePresenter::SuccessPresenter.new(nil, params, messages)
  end

  protected
  def create_report
    role_id = UserRole.id_for(:employee)
    memo = auto_submit_config.default_memo
    self.report = selected_user.reports.build report_status_id: ReportStatus.open_id, controlling_user: selected_user,
                                              controlling_user_role_id: role_id, policy_id: auto_submit_config.default_policy_id,
                                              name: params[:name], auto_submit: true, memo: memo
    if report.save
      Reports::Expenses::Add.(selected_user, {selected_user: selected_user, report: report, expenses: processing_expenses, auto_submit: true})
    else
      add_message :error, report.errors.full_messages
    end
  end

  def validate_report
    # checking for blocking violations
    violations = Reports::Violation.(nil, report: report)
    violations_present = false
    violations.each do |key, value|
      blocking_violations_present ||= (value['expense_blocking'].present? or value['budget_blocking'].present?)
      self.has_violations ||= (blocking_violations_present or  value['budget_warning'].present? or value['expense_warning'].present?)
      break if blocking_violations_present
    end
    if violations_present
      add_message :error, 'Reports with blocking violations cannot be submitted'
    end
  end

  def submit_report
    presenter = User::Team::Review::NextReviewer.(report, has_violations: self.has_violations)
    manager = presenter.user
    manager_role_id = presenter.role_id

    comment = report.comments.create user: selected_user, report_comment_action_id: ReportCommentAction.id_for(:report_auto_submit)

    # If no manager assigned, auto approve the report
    if manager.blank?
      # call the approve class with the right parameters
      approve_op = Reports::Approve.new(selected_user, {report: self.report, auto_approve: true, auto_submit: true})
      unless approve_op.run.success?
        self.add_message :error, approve_op.messages[:error]
        comment.destroy
        return false
      end
      report.reload

      # changing the status of the expenses in the auto approved report.
      report.expenses.each do |expense|
        expense.update_attribute(:expense_status_id, ExpenseStatus.submitted_id)
      end
      return true
    end
    # memo = auto_submit_config.default_memo
    submitted_amount_attributes = {value: report.total_amount, currency_id: 1}
    if report.submitted_amount_id
      submitted_amount_attributes[:id] = report.submitted_amount_id
    end
    submitted_at = DateTime.now
    if report.update_attributes report_status_id: ReportStatus.processing_id,
                                controlling_user_id: manager.id,
                                controlling_for_user_id: nil,
                                controlling_user_role_id: manager_role_id,
                                controlling_for_user_role_id: nil,
                                submitted_at: submitted_at,
                                submitted_amount_attributes: {value: report.total_amount, currency_id: 1}
      # report.tracks.create action_user: selected_user,
      #                      action_user_role_id: manager_role_id,
      #                      modified_user_id: report.controlling_user_id,
      #                      modified_user_role_id: manager_role_id,
      #                      report_tracking_action_id: ReportTrackingAction.id_for(:submit),
      #                      report_status_id: ReportStatus.processing_id
      report.trails.create action_user: selected_user,
                           action_user_role_id: manager_role_id,
                           action_id: TrailAction.id_for(:submit)



      report.comments.create user: selected_user, report_comment_action_id: ReportCommentAction.id_for(:report_auto_submit)
      report.expenses.each do |expense|
        expense.update_attribute(:expense_status_id, ExpenseStatus.submitted_id)
      end
      return true
    end
    add_message :error, report.errors.full_messages
  end

end