class ReportCommentsFix < BaseJob

  def self.perform_job
    puts " ----------------------------- PERFORMING #{self.name} at #{Time.now.strftime("%d-%B-%Y %H:%M:%S")} ------------------------------"
    Company.where.not(id:[1,2]).each do |company|
      ActsAsTenant.current_tenant = company
      next if (company.feature_subscription.expense_management_enabled == false)
      Report.where('submitted_at > ?', Date.parse('01-June-2021')).where(company_id: company.id).each do |report|
        first_dlrm = report.dlrms.first
        next if first_dlrm.action_taken_at.nil?

        if first_dlrm.forwarded_to_id.present?
          reviewer = first_dlrm.forwarded_to
        elsif first_dlrm.taken_control_by_id.present?
          reviewer = first_dlrm.taken_control_by
        else
          reviewer = first_dlrm.reviewer
        end

        comment = report.comments.where('created_at > ?', report.submitted_at).where(user_id: reviewer.id,report_comment_action_id: ReportCommentAction.id_for(:report_approve)).first
        next if comment.present?
        comment = report.comments.build user: reviewer, report_comment_action_id: ReportCommentAction.id_for(:report_approve), created_at: first_dlrm&.action_taken_at, updated_at: first_dlrm.action_taken_at
        comment.save
      end
    end
  end
end