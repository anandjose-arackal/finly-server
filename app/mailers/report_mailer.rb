class ReportMailer < ApplicationMailer

  def send_mail(presenter)
    return unless presenter.validate
    @data = presenter
    #### variables required for the attachment pdf #########
    @result = Report::Show.(@data.user, {report_id: @data.report.id, role_id: @data.role_id})
    @report = @data.report
    @current_user = @data.user
    @include_comments = false
    ########################################################
    attachments["report-#{@data.report.name}.pdf"] = WickedPdf.new.pdf_from_string(
       render_to_string(pdf: "report-#{@data.report.name}", template: "export/report", layout: "pdf.html.erb", print_media_type: true)
    )
    mail to: presenter.to, subject: presenter.subject, template_name: 'template'
  end

end