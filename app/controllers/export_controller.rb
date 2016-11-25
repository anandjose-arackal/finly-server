class ExportController < ApplicationController
  include MathUtil

  before_action :authenticate_user!

  def report
    respond_to do |format|
      format.csv {
        @report = Export::AsCsv.(current_user, params)
        send_data @report.data
      }
      format.xls {
        @report = Export::AsXml.(current_user, params)
        @header = @report.header
        @data = @report.data
      }
      format.pdf {
        @report = Report::Show.new(current_user, params).run
        render pdf: "report-#{@report.report.name}", layout: "pdf.html.erb"
      }
    end
  end

  def statement
    respond_to do |format|
      format.csv {
        @employee_statement = EmployeeStatement::Export::AsCsv.(current_user, params)
        send_data @employee_statement.data
      }
      format.xls {
        @employee_statement = EmployeeStatement::Export::AsXls.(current_user, params)
        @header = @employee_statement.header
        @data = @employee_statement.data
      }
      format.pdf {
        # todo - need to create view for this
      }
    end
  end

end
