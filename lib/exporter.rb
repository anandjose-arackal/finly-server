# Usage Exporter is a parent class
# Example: Exporter.new(user, spreadsheet: {headers: self.headers, contents: self.contents, filename: 'assign_card'}, pdf: {template: 'report.pdf.erb', filename: 'assign_card', local_variables: {report: self.report}}, messages)
class Exporter < BaseOperation::BasePresenter::SuccessPresenter
  attr_accessor :pdf_exporter, :spreadsheet_exporter

  def init
    if params[:spreadsheet].present?
      self.spreadsheet_exporter= Exporter::Spreadsheet.new user, params[:spreadsheet], messages
    end
    if params[:pdf].present?
      self.pdf_exporter = Exporter::Pdf.new user, params[:pdf], messages
    end
  end

  def render(controller)
    controller.respond_to do |format|
      if self.spreadsheet_exporter.present?
        format.csv { self.spreadsheet_exporter.render_csv controller }
        format.xls { self.spreadsheet_exporter.render_xls controller }
      end
      if self.pdf_exporter.present?
        format.pdf { self.pdf_exporter.render_pdf controller }
      end
    end
  end

  # NOTE: THIS CAN BE USED INDEPENDENTLY. I.E THIS CAN BE INSTANTIATED AND USED like in the example below
  # Usage
  # Example: Exporter::Pdf.new(user, {template: 'report.pdf.erb', filename: 'assign_card', local_variables: {report: self.report}}, messages)
  class Exporter::Pdf < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :filename, :template, :local_variables

    def init
      self.filename = params[:filename]
      self.template = params[:template]
      self.local_variables = params[:local_variables]
    end

    def render(controller)
      controller.respond_to do |format|
        format.pdf { render_pdf controller }
      end
    end

    def render_pdf(controller)
      self.filename = 'export' if self.filename.blank?
      self.filename += '.pdf' unless self.filename.include? '.pdf'
      if self.template.blank?
        raise 'PDF template not found'
        return
      end
      controller.render pdf: self.filename, layout: self.template, print_media_type: true, locals: local_variables
    end

  end

  # NOTE: THIS CAN BE USED INDEPENDENTLY. I.E THIS CAN BE INSTANTIATED AND USED like in the example below
  # Usage
  # Example: Exporter::Spreadsheet.new(user, {headers: self.headers, contents: self.contents, filename: 'assign_card'}, messages)
  class Exporter::Spreadsheet < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :headers, :contents, :filename

    def init
      self.headers = params[:headers]
      self.contents = params[:contents]
      self.filename = params[:filename]
    end

    def render(controller)
      controller.respond_to do |format|
        format.csv { render_csv controller }
        format.xls { render_xls controller }
      end
    end

    # Handle XLS START
    def render_xls(controller)
      controller.render xls_template, locals: {headers: self.headers, contents: self.contents}
    end

    def xls_template
      'export_template/template'
    end

    # Handle XLS END

    # Handle CSV Start
    def render_csv(controller)
      result = generate_csv
      self.filename = 'finly_export' if self.filename.blank?
      self.filename += '.csv' unless self.filename.include? '.csv'
      controller.send_data result, filename: self.filename
    end

    def generate_csv
      CSV.generate do |csv|
        csv << self.headers if self.headers
        self.contents&.each do |content|
          csv << content
        end
      end
    end
    # Handle CSV END

  end
end