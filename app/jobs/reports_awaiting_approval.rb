class ReportsAwaitingApproval < BaseJob

  def self.perform_job
    company_list = Company.where(id: [144])
    company_list.each do |company|
      remind_document_reviewer(company)      
    end
  end

  private

  def self.remind_document_reviewer(company)
    users = company.managers

    users.each do |user|
      reports = Report.awaiting_action_items(user.id)
      reports = reports.where('submitted_at <= ?', 3.days.ago)
      if reports.present?
        Event::EDocument::ReportsAwaitingApproval.(user, reports: reports)
      end
    end
  end

end