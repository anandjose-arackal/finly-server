# action that approves a report.
# params:
# report_id: id of the report that needs to be approved
# auto_approve : optional - set to true if the report is to be auto-approved. i.e. if there is no reporting manager

class Report::BulkApprove < BaseOperation
  attr_accessor :auto_approve, :auto_submit, :multiple_reports, :valid, :confirm_approve, :approved_all

  def authorized_user_types
    return nil if params.present? and (params[:auto_approve] or params[:auto_submit] )
    [:manager, :finance_manager, :admin]
  end

  def pre_validate
    if params.blank?
      add_message :error, 'Error loading configuration'
    end
  end

  def init
    self.multiple_reports = {}
    self.valid = true
    self.approved_all = true
    # self.reports_errors = {}
    report_ids_cs = params[:report_ids] || ""
    report_ids = report_ids_cs.split(",")
    self.confirm_approve = params[:confirm_approve]
    report_ids.each_with_index do |report_id, index|
      self.multiple_reports[index] = {}
      self.multiple_reports[index][:report] = Report.find(report_id)
      self.multiple_reports[index][:errors] = []
      self.multiple_reports[index][:notices] = []
      self.multiple_reports[index][:violations] = {}
      self.multiple_reports[index][:violations][:warning] = []
      self.multiple_reports[index][:violations][:blocking] = []

    end

    # self.report = params[:report]
    # if self.report.blank?
    #   id = (params[:id] or params[:report_id])
    #   self.report = user.controlling_reports.with_id(id).first rescue nil
    # end
    # self.auto_approve = (params[:auto_approve] or false)
    # self.auto_submit = params[:auto_submit]
  end

  def authorize
    # unless report
    #   raise_unauthorized_exception
    # end
    # unless auto_approve or report.controlling_user_id == user.id
    #   raise_unauthorized_exception
    # end

    for key, value in self.multiple_reports
      unless value[:report]
        raise_unauthorized_exception
      end

      unless value[:report].controlling_user_id == user.id
        value[:errors] << "You are not the controlling user."
        # Do something else todo
        # raise_unauthorized_exception
      end
    end
  end

  def validate
    # self.has_errors = false
    for key, value in self.multiple_reports
      unless value[:report].processing?
        value[:errors] << "Cannot approve this report as it is not in processing state"
      end

      violations = Report::Violation.(user, report: value[:report])
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
      end

    end
    # unless report.processing? or auto_approve
    #   add_message :error, 'Cannot approve this report as it is not in processing state'
    # end


    # violations = Report::Violation.(user, report: report)
    # violations_present = false
    # violations.each do |key, value|
    #   if value['expense_blocking'].present? or value['budget_blocking'].present?
    #     violations_present = true
    #   end
    # end
    # if violations_present
    #   add_message :error, 'Reports with blocking violations cannot be submitted'
    # end
  end

  def process
    if valid
      if confirm_approve
        # Process reports
        for key, value in multiple_reports
          report = value[:report]
          presenter = User::Team::Review::NextReviewer.(report)
          manager = presenter.user
          to_user_role_id = presenter.role_id
          status = ReportStatus.processing_id
          if manager.blank?
            status = ReportStatus.approved_id
            # if the report has no reimbursable expenses, mark it as closed because there are no reimbursements
            if report.expenses.only_reimbursable_expenses.count == 0 && report.only_card_expenses?
              status = ReportStatus.closed_id
            end
          end

          if status == ReportStatus.approved_id || status == ReportStatus.closed_id
            approved_at = DateUtils.local_date_time
          else
            approved_at = nil
          end

          curr_user_role = User::Team::Review::UserRole.(user, report)
          update_attributes = {report_status_id: status,
                               controlling_user: manager,
                               controlling_for_user_id: nil,
                               controlling_user_role_id: to_user_role_id,
                               controlling_for_user_role_id: nil,
                               # auto_approve: auto_approve,
                               approved_at: approved_at}
          # update_attributes[:submitted_at] = DateTime.now if auto_approve
          if report.update_attributes update_attributes
            
            track = report.tracks.build action_user: user,
                                        modified_user_id: report.controlling_user_id,
                                        modified_user_role_id: to_user_role_id,
                                        report_tracking_action_id: ReportTrackingAction.id_for(:approve),
                                        report_status_id: status,
                                        action_user_role_id: curr_user_role
            track.save

            if report.closed?
              track = report.tracks.build action_user: nil,
                                          modified_user: nil,
                                          report_tracking_action_id: ReportTrackingAction.id_for(:closed),
                                          report_status_id: ReportStatus.closed_id
              track.save
            end
          else
            self.approved_all = false
            value[:errors] += report.errors.full_messages
          end

          # value[:errors] += report.errors.full_messages
          # add_message :error, report.errors.full_messages
        end
        # add_message :success, "Reports will be approved."
      end
    else
      add_message :error, "Please fix the errors"
    end
    # presenter = User::Team::Review::NextReviewer.(report)
    # manager = presenter.user
    # to_user_role_id = presenter.role_id
    # status = ReportStatus.processing_id
    # if auto_approve or manager.blank?
    #   status = ReportStatus.approved_id
    #   # if the report has no reimbursable expenses, mark it as closed because there are no reimbursements
    #   if report.expenses.only_reimbursable_expenses.count == 0
    #     status = ReportStatus.closed_id
    #   end
    # end
    # if status == ReportStatus.approved_id || status == ReportStatus.closed_id
    #   approved_at = DateUtils.local_date_time
    # else
    #   approved_at = nil
    # end
    # curr_user_role = User::Team::Review::UserRole.(user, self.report)
    # update_attributes = {report_status_id: status,
    #                      controlling_user: manager,
    #                      controlling_for_user_id: nil,
    #                      controlling_user_role_id: to_user_role_id,
    #                      controlling_for_user_role_id: nil,
    #                      auto_approve: auto_approve,
    #                      approved_at: approved_at}
    # update_attributes[:submitted_at] = DateTime.now if auto_approve
    # if report.update_attributes update_attributes
    #   if auto_approve
    #     track = report.tracks.build action_user: nil,
    #                                 modified_user: nil,
    #                                 report_tracking_action_id: ReportTrackingAction.id_for(:auto_approve),
    #                                 report_status_id: status
    #   else
    #     track = report.tracks.build action_user: user,
    #                                 modified_user_id: report.controlling_user_id,
    #                                 modified_user_role_id: to_user_role_id,
    #                                 report_tracking_action_id: ReportTrackingAction.id_for(:approve),
    #                                 report_status_id: status,
    #                                 action_user_role_id: curr_user_role
    #   end
    #   track.save

    #   if report.closed?
    #     track = report.tracks.build action_user: nil,
    #                                 modified_user: nil,
    #                                 report_tracking_action_id: ReportTrackingAction.id_for(:closed),
    #                                 report_status_id: ReportStatus.closed_id
    #     track.save
    #   end
    #   return true
    # end
    # add_message :error, report.errors.full_messages
  end

  def post_process
    if valid
      if confirm_approve
        if approved_all
          for key, value in self.multiple_reports
            report = value[:report]
            comment = report.comments.build user: user, report_comment_action_id: ReportCommentAction.id_for(:report_approve)
            comment.save

            # set the reimbursement amount of the report
            unless report.processing?
              Settlement::Report::Approved.(user, report: report)
              report.reload
            end
            # if report is closed, add the relevant comment
            if report.closed?
              # Add comments stating report has been closed as no reimbursements required
              comment = report.comments.build(user: nil,
                                              report_comment_action_id: ReportCommentAction.id_for(:report_closed),
                                              content: " as there are no reimbursable expenses")
              comment.save
            end
            # Send notifications
            Event::EReport::Approve.(self.user, report: report, auto_approve: auto_approve)

            value[:notices].push('Report Approved!')
          end
        end
      end
    end
  end

  def success
    params[:multiple_reports] = self.multiple_reports
    Report::BulkApprove::SuccessPresenter.new(user, params, messages)
  end



  def failure
    params[:reports_errors] = self.multiple_reports
    Report::BulkApprove::FailurePresenter.new(user, params, messages)
  end

  class Report::BulkApprove::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :multiple_reports
    def init
      self.multiple_reports = params[:multiple_reports]
    end

    def reports_with_data
      ar = []
      for key, value in self.multiple_reports
        ar.push(value)
      end
      ar
    end
  end

  class Report::BulkApprove::FailurePresenter < BaseOperation::BasePresenter::FailurePresenter
    attr_accessor :multiple_errors
    def init
      self.multiple_errors = params[:reports_errors]
    end

    def reports_with_errors
      ar = []
      for key, value in self.multiple_errors
        ar.push(value)
      end
      ar
    end
  end
end