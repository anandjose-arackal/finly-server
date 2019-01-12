class Integrations::Quickbooks::InitiateReportsSync < Integrations::Quickbooks::Base

  attr_accessor :reports

  def self.call(user, params)
    self.new(user, params).run
  end

  def initialize(user, params)
    self.user = user
    params ||= {}
    if params.class.name == ActionController::Parameters.name
      self.params = params
    else
      self.params = (ActionController::Parameters.new(params) or {})
    end
  end

  def pre_validate
    if user.authentications.valid.empty?
      add_message :error, "You haven't connected to quickbooks yet, please connect your account and try again"
      return
    end
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def init
    user_ids = user.company.users.pluck(:id)
    ids = params[:report_ids] || params[:report_id]
    self.reports = Report.with_user(user_ids).where(id: ids)
  end

  def validate
    if reports.empty?
      add_message :error, "You need to select at least one report to sync"
      return
    end

    invalid_reports = []
    reports.each do |report|
      unless [ReportSyncStatus.id_for(:not_synced), ReportSyncStatus.id_for(:partially_synced), nil].include?(report.sync_status_id)
        invalid_reports << report
      end
    end

    unless invalid_reports.empty?
      add_message :error, "Some of these reports have already been synced or are currently being synced in quickbooks - please uncheck them and try again"
      return
    end

    reports.each do |report|
      unless report.processed?
        add_message :error, "Only processed reports can be exported to Quickbooks. Some of these reports have not been processed yet"
        return
      end
    end
  end

  def pre_process
    # setting the status as in progress for all these reports
    reports.each do |report|
      report.update(sync_status_id: ReportSyncStatus.id_for(:in_progress))
    end
  end

  def process
    Integrations::Quickbooks::SyncReports.call_async(user.id, report_ids: reports.pluck(:id))
    # Integrations::Quickbooks::SyncReports.(user.id, report_ids: reports.pluck(:id))
  end

  def post_process
    add_message :success, "Report sync initiated"
  end
end