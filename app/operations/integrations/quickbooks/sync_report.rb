class SyncReport < Integrations::Base

  attr_accessor :report

  def pre_validate
    if company.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def init
    self.report = params[:report]
    if report.blank?
      user_ids = company.users
      self.report = Report.with_user(user_ids).find_by(id: params[:report_id])
    end
  end

  def validate
    if report.synced_with_quickbooks
      add_message :error, "This report is already synced with quickbooks"
    end
  end

  def process
    unless adapter.save_report(report)
      add_message :error, adapter.save_report(report)
    end
  end

  def post_process
    # mark the report as synced with quickbooks so that you don't have to sync it again
    report.update(synced_with_quickbooks: true)
  end
end