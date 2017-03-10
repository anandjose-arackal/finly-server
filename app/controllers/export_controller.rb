class ExportController < ApplicationController
  include MathUtil

  before_action :authenticate_user!

  def report
    respond_to do |format|
      format.csv {
        @report = Export::Report::AsCsv.(current_user, params)
        send_data @report.data, filename: "#{@report.report_names}"
      }
      format.xls {
        @report = Export::Report::AsXml.(current_user, params)
        @header = @report.header
        @data = @report.data
      }
      format.pdf {
        @result = Report::Show.(current_user, params)
        @report = @result.report
        render pdf: "report-#{@report.name}", layout: "pdf.html.erb", print_media_type: true
      }
    end
  end

  def statement
    respond_to do |format|
      format.csv {
        @employee_statement = Export::CardStatement::AsCsv.(current_user, params)
        send_data @employee_statement.data
      }
      format.xls {
        @employee_statement = Export::CardStatement::AsXls.(current_user, params)
        @header = @employee_statement.header
        @data = @employee_statement.data
      }
      format.pdf {
        # todo - need to create view for this
      }
    end
  end

end
