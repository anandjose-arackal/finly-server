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

  def process
    unless adapter.save_report(report)
      add_message :error, "Report could not be saved, try again later"
    end
  end
end