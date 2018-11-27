class ReportMailer < ApplicationMailer

  def send_mail(presenter)
    return unless presenter.validate
    @data = presenter
    #### variables required for the attachment pdf #########
    @result = Report::Show.(@data.user, {report_id: @data.report.id, role_id: @data.role_id, view: UserRole.name_for(@data.role_id)})
    if @result.success?
      @report = @data.report
      @curr_user = @data.user
      @include_comments = false
      receipts = Receipt.with_expense_id(@report.expenses.pluck(:id))
      local_variables = {
          report: @report,
          receipts: receipts,
          includes_comments: true,
          op: @result,
          current_user: @curr_user
      }
      ########################################################
      attachments["report-#{@data.report.name}.pdf"] = WickedPdf.new.pdf_from_string(
         render_to_string(pdf: "report-#{@data.report.name}", template: "export/report", layout: "pdf.html.erb", locals: local_variables, print_media_type: true)
      )
      mail to: presenter.to, subject: presenter.subject, template_name: 'template'
    end
  end
end