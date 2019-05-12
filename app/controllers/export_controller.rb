class ExportController < BaseControllers::WebBase
  include MathUtil

  before_action :set_tokens_in_header


  def report
    respond_to do |format|
      format.csv {
        @report = Export::Reports::AsCsv.(current_user, params)
        send_data @report.data, filename: "#{@report.report_names}.csv"
      }
      format.xls {
        @report = Export::Reports::AsXml.(current_user, params)
        @header = @report.header
        @data = @report.data
      }
      format.pdf {
        op = Reports::ExportHandler.(current_user, params)
        local_variables = op.local_variables
        template = op.template
        local_variables[:op] = op
        @result = Exporter::Pdf.new(current_user, {filename: "report-#{op.report.name}", layout: 'pdf.html.erb', template: template, local_variables: local_variables})
        @result.render(self)
      }
      format.zip {
        @result = Export::Reports::WithReceipts.(current_user, params)
        if @result.success?
          @result.render self
        else
          render json: {success: false}
        end
      }
    end
  end

  def expense
    respond_to do |format|
      format.csv {
        @result = Expense::Exports::AsCsv.(current_user, params)
        send_data @result.data, filename: "#{@result.file_name}"
      }
      format.xls {
        @result = Expense::Exports::AsXml.(current_user, params)
      }
      format.zip {
        @result = Expense::Exports::WithReceipts.(current_user, params)
        if @result.success?
          @result.render self
        else
          render json: {success: false}
        end
      }
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

  def money_request
    respond_to do |format|
      format.csv {
        @money_request = Export::MoneyRequest::AsCsv.(current_user, params)
        send_data @money_request.data, filename: "#{@money_request.money_request_name}.csv"
      }
      format.xls {
        @money_request = Export::MoneyRequest::AsXml.(current_user, params)
        @header = @money_request.header
        @data = @money_request.data
      }
    end
  end

  def payment_file

  end

  def index_template
    @result = Personalizer::ExportTemplates.(current_user)
    respond
  end

  def export_template
    @result = Personalizer::ProcessTemplate.(current_user, params)
    respond
  end

  def processor
    @result = ExportManager::RequestHandler.(current_user, params)
    respond
  end

end
