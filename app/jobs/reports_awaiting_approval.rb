class ReportsAwaitingApproval < ApplicationJob

  def perform
    company_list = Company.where(id: [164]) # satin
    company_list.each do |company|
      remind_document_reviewer(company)      
    end
  end

  private

  def remind_document_reviewer(company)
    au = company.admins.first
    reports = Report.admin_associated_items(au).not_open.exclude_deleted.where(report_status_id: ReportStatus.id_for(:processing))
    reports = reports.where('submitted_at <= ?', 3.days.ago)
    if reports.present?
      result = reports.map {|report| [report.get_reviewers.first.id, report.id]}.compact.group_by {|user_id, report_id| user_id }.map {|user_id, report_id| [user_id, report_id.map(&:last)] }.to_h
      users = User.where(company_id: company.id, id: result.keys)
      users.each do |user|
        Event::EDocument::ReportsAwaitingApproval.(user, reports: reports, report_ids: result[user.id])
      end
    end
  end

end