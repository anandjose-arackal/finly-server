class Integrations::Quickbooks::InitiateReportsSync < Integrations::Quickbooks::Base

  attr_accessor :reports

  def authorized_user_types
    [:company_admin, :finance]
  end

  def init
    user_ids = user.company.users.pluck(:id)
    self.reports = Report.with_user(user_ids).where(id: params[:report_ids])
  end

  def validate
    invalid_reports = []
    reports.each do |report|
      unless report.sync_status_id == ReportSyncStatus.id_for(:not_synced)
        invalid_reports << report
      end
    end

    unless invalid_reports.empty?
      add_message :error, "Some of these reports have already been synced or are currently being synced in quickbooks - please uncheck them and try again"
      return
    end
  end

  def process

  end
end