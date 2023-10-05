# action that approves a report.
# params:
# report_id: id of the report that needs to be approved
# auto_approve : optional - set to true if the report is to be auto-approved. i.e. if there is no reporting manager

class Reports::BulkApprove < BaseOperation
  attr_accessor :auto_approve, :auto_submit, :multiple_reports, :valid, :confirm_approve, :approved_all, :failure_count, :success_count, :invalid_count, :async

  def authorized_user_types
    return nil if params.present? and ( params[:auto_approve] or params[:auto_submit] )

    [:manager, :finance_manager, :admin]
  end

  def pre_validate
    if params.blank?
      add_message :error, 'Error loading configuration'
    end
  end

  def init
    self.async = params[:async] || false
    self.multiple_reports = {}
    self.valid = true
    self.approved_all = true
    # self.reports_errors = {}
    report_ids_cs = params[:report_ids] || ''
    report_ids = report_ids_cs.split(',')
    self.confirm_approve = params[:confirm_approve]
    reports = Report.where(id: report_ids) rescue []
    reports.each_with_index do |report, index|
      self.multiple_reports[index] = {}
      self.multiple_reports[index][:report] = report
      self.multiple_reports[index][:errors] = []
      self.multiple_reports[index][:notices] = []
      self.multiple_reports[index][:violations] = {}
      self.multiple_reports[index][:violations][:warning] = []
      self.multiple_reports[index][:violations][:blocking] = []
    end

    self.failure_count = 0
    self.success_count = 0
    self.invalid_count = 0

    # self.report = params[:report]
    # if self.report.blank?
    #   id = (params[:id] or params[:report_id])
    #   self.report = user.controlling_reports.with_id(id).first rescue nil
    # end
    # self.auto_approve = (params[:auto_approve] or false)
    # self.auto_submit = params[:auto_submit]
  end

  def authorize
    return true if async

    self.multiple_reports.each do |key, value|
      unless value[:report]
        raise_unauthorized_exception
      end

      unless value[:report].get_reviewers.include?(user)
        value[:errors] << 'You are not the controlling user.'
        # Do something else todo
        # raise_unauthorized_exception
      end
    end
  end

  def validate
    return true if async

    self.multiple_reports.each do |key, value|
      unless value[:report].processing?
        value[:errors] << "Cannot approve this report as it is not in processing state"
      end

      violations = Reports::Violation.(user, report: value[:report])
      violations_present = false
      warning_messages = []
      blocking_messages = []
      violations.each do |key, violation|

        warning_messages.concat violation[:expense_warning] if violation[:expense_warning].present?
        warning_messages.concat violation[:budget_warning] if violation[:budget_warning].present?
        warning_messages.concat violation['expense_warning'] if violation['expense_warning'].present?
        warning_messages.concat violation['budget_warning'] if violation['budget_warning'].present?

        blocking_messages.concat violation[:expense_blocking] if violation[:expense_blocking].present?
        blocking_messages.concat violation[:budget_blocking] if violation[:budget_blocking].present?
        blocking_messages.concat violation['expense_blocking'] if violation['expense_blocking'].present?
        blocking_messages.concat violation['budget_blocking'] if violation['budget_blocking'].present?
      end

      if blocking_messages.size > 0
        blocking_messages.uniq!
        Formatter.remove_blanks blocking_messages
      end


      if warning_messages.size > 0
        warning_messages.uniq!
        Formatter.remove_blanks warning_messages
      end

      value[:violations][:warning] += warning_messages
      value[:violations][:blocking] += blocking_messages

      if blocking_messages.present?
        value[:errors] << 'Reports with blocking violations cannot be approved.'
      end

      unless value[:errors].blank?
        self.valid = false
        self.invalid_count += 1
      end

    end
  end

  def process
    if valid
      if confirm_approve
        # Process reports
        if multiple_reports.count > 10 && !async
          worker_params = {
            confirm_approve: true,
            report_ids: params[:report_ids],
            async: true
          }
          BulkApproveWorker.perform_async(user.id, worker_params.stringify_keys)
          add_message :success, 'Your reports will be approved!'
        else
          multiple_reports.each do |key, value|
            report = value[:report]
            has_violations = (value[:violations][:warning].present? or value[:violations][:blocking].present?)
            params[:document] = report
            params[:aasm_event] = 'approve'
            op = WorkflowManager::Base.(user, params)

            unless op.success?
              add_message :error, op.messages[:error]
              self.approved_all = false
              value[:error] += op.messages[:error]
              self.failure_count += 1
            else
              self.success_count += 1
            end
          end
        end
      end
    else
      add_message :error, "#{invalid_count} reports were invalid. Please fix the issues."
    end
  end

  def post_process
    if valid && confirm_approve && should_post_process?
      self.multiple_reports.each do |key, value|
        unless value[:errors].present?
          report = value[:report]
          comment = report.comments.build user: user, report_comment_action_id: ReportCommentAction.id_for(:report_approve)
          comment.save

          # set the reimbursement amount of the report
          unless report.processing?
            Settlement::SReport::Approved.(user, report: report)
            report.reload
          end
          # if report is closed, add the relevant comment
          if report.closed?
            # Add comments stating report has been closed as no reimbursements required
            comment = report.comments.build(user: nil,
                                            report_comment_action_id: ReportCommentAction.id_for(:report_closed),
                                            content: ' as there are no reimbursable expenses')
            comment.save
          end
          # Send notifications
          Event::EReport::Approve.(self.user, report: report, auto_approve: auto_approve)

          value[:notices].push('Report Approved!')
        end
      end
    end
  end

  def success
    params[:multiple_reports] = self.multiple_reports
    if approved_all && confirm_approve
      success_message = "#{(success_count).to_i} reports approved"
    elsif confirm_approve
      success_message = "#{success_count.to_i} reports approved out of #{(success_count+failure_count).to_i}"
    end

    add_message :success, success_message if multiple_reports.count <= 10
    Reports::BulkApprove::SuccessPresenter.new(user, params, messages)
  end

  def failure
    params[:reports_errors] = self.multiple_reports
    Reports::BulkApprove::FailurePresenter.new(user, params, messages)
  end

  private

  def should_post_process?
    return true if self.multiple_reports.count <= 10 || self.async
  end

  class Reports::BulkApprove::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :multiple_reports

    def init
      self.multiple_reports = params[:multiple_reports]
    end

    def reports_with_data
      ar = []
      self.multiple_reports.each do |key, value|
        ar.push(value)
      end
      ar
    end
  end

  class Reports::BulkApprove::FailurePresenter < BaseOperation::BasePresenter::FailurePresenter
    attr_accessor :multiple_errors

    def init
      self.multiple_errors = params[:reports_errors]
    end

    def reports_with_errors
      ar = []
      self.multiple_errors.each do |key, value|
        ar.push(value)
      end
      ar
    end
  end
end