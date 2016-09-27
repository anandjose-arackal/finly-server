class ExportController < ApplicationController
  include MathUtil

  before_action :authenticate_user!

  def report
    respond_to do |format|
      format.csv {
        @report = Export::AsCsv.new(current_user, params).run
        send_data @report.data
      }
      format.xls {
        @report = Export::AsXml.new(current_user, params).run
        @header = @report.header
        @data = @report.data
      }
      format.pdf {
        @report = Report::Show.new(current_user, params).run
        render pdf: "report-#{@report.report.name}", layout: "pdf.html.erb"
      }
    end
  end

end
