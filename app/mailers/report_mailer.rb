class ReportMailer < ApplicationMailer

  def submit(report, user)
    return if user.blank? or report.blank?

  end

end
