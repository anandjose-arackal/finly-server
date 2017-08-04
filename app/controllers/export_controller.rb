class ExportController < ApplicationController
  include MathUtil

  before_action :set_tokens_in_header
  #
  before_action -> { finly_authorize! :web}

  def report
    respond_to do |format|
      format.csv {
        @report = Export::Report::AsCsv.(current_user, params)
        send_data @report.data, filename: "#{@report.report_names}.csv"
      }
      format.xls {
        @report = Export::Report::AsXml.(current_user, params)
        @header = @report.header
        @data = @report.data
      }
      format.pdf {
        @result = Report::Show.(current_user, params)
        @report = @result.report
        @current_user = current_user
        @include_comments = true
        render pdf: "report-#{@report.name}", layout: "pdf.html.erb", print_media_type: true
      }
    end
  end

  def expense
    respond_to do |format|
      format.csv {
        @result = Expense::Export::AsCsv.(current_user, params)
        send_data @result.data, filename: "#{@result.file_name}"
      }
      format.xls {
        @result = Expense::Export::AsXml.(current_user, params)
      }
      # format.pdf {
      #   @result = Report::Show.(current_user, params)
      #   @report = @result.report
      #   @current_user = current_user
      #   @include_comments = true
      #   render pdf: "report-#{@report.name}", layout: "pdf.html.erb", print_media_type: true
      # }
    end
  end

  def atm_transactions
    respond_to do |format|
      format.csv {
        @result = Card::Export::Transaction::AsCsv.(current_user, params)
        send_data @result.data, filename: "#{@result.file_name}.csv"
      }
      format.xls {
        @result = Card::Export::Transaction::AsXml.(current_user, params)
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

  private



end
