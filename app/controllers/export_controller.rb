class ExportController < ApplicationController
  include MathUtil

  before_action :set_tokens_in_header

  before_action -> {finly_authorize! :web}

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
        if current_company.id == 129
          send_file(
            "#{Rails.root}/app/assets/pdf_templates/learning_links_export.pdf",
            filename: "report_export.pdf",
            type: 'application/pdf'
          )
        else
          op = Report::ExportHandler.(current_user, params)
          local_variables = op.local_variables
          template = op.template
          local_variables[:op] = op
          @result = Exporter::Pdf.new(current_user, {filename: "report-#{op.report.name}", layout: 'pdf.html.erb', template: template, local_variables: local_variables})
          # render pdf: "report-#{op.report.name}", layout: "pdf.html.erb", print_media_type: true
          @result.render(self)
        end
      }
      format.zip {
        @result = Export::Report::WithReceipts.(current_user, params)
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
