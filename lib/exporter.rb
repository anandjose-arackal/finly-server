require 'rubygems'
require 'zip'
# Usage Exporter is a parent class
# Example: Exporter.new(user, spreadsheet: {headers: self.headers, contents: self.contents, filename: 'assign_card'}, pdf: {template: 'report.pdf.erb', filename: 'assign_card', local_variables: {report: self.report}}, messages)
class Exporter < BaseOperation::BasePresenter::SuccessPresenter
  attr_accessor :pdf_exporter, :spreadsheet_exporter, :zip_exporter, :xml_exporter

  def init
    if params[:spreadsheet].present?
      self.spreadsheet_exporter = Exporter::Spreadsheet.new user, params[:spreadsheet], messages
    end
    if params[:pdf].present?
      self.pdf_exporter = Exporter::Pdf.new user, params[:pdf], messages
    end
    if params[:zip].present?
      self.zip_exporter = Exporter::AsZip.new user, params[:zip], messages
    end
    if params[:xml].present?
      self.xml_exporter = Exporter::Xml.new user, params[:xml], messages
    end
  end

  def render(controller)
    controller.respond_to do |format|
      if self.spreadsheet_exporter.present?
        format.csv {self.spreadsheet_exporter.render_csv controller}
        format.xls {self.spreadsheet_exporter.render_xls controller}
      end
      if self.pdf_exporter.present?
        format.pdf {self.pdf_exporter.render_pdf controller}
      end
      if self.zip_exporter.present?
        format.zip {self.zip_exporter.render_zip controller}
      end
      if self.xml_exporter.present?
        format.xml {self.xml_exporter.render_xml controller}
      end
    end
  end

  class Exporter::BaseSuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :filename

    def init
      self.filename = params[:filename]
    end

  end

  # NOTE: THIS CAN BE USED INDEPENDENTLY. I.E THIS CAN BE INSTANTIATED AND USED like in the example below
  # Usage
  # Example: Exporter::Pdf.new(user, {template: 'report.pdf.erb', filename: 'assign_card', local_variables: {report: self.report}}, messages)
  class Exporter::Pdf < Exporter::BaseSuccessPresenter
    attr_accessor :template, :local_variables, :layout

    def init
      super
      self.template = params[:template]
      self.layout = params[:layout]
      self.local_variables = params[:local_variables]
    end

    def render(controller)
      controller.respond_to do |format|
        format.pdf {render_pdf controller}
      end
    end

    def generate_pdf

    end

    def render_pdf(controller)
      self.filename = 'export' if self.filename.blank?
      self.filename += '.pdf' unless self.filename.include? '.pdf'
      if self.template.blank?
        raise 'PDF template not found'
        return
      end
      controller.render pdf: self.filename, layout: self.layout, template: self.template, print_media_type: true, locals: local_variables
    end

  end

  # NOTE: THIS CAN BE USED INDEPENDENTLY. I.E THIS CAN BE INSTANTIATED AND USED like in the example below
  # Usage
  # Example: Exporter::Spreadsheet.new(user, {headers: self.headers, contents: self.contents, filename: 'assign_card'}, messages)
  # Additionally if multiple sheets are to be generated, pass the headers and contents of each sheet as an array of hashes
  # format:
  # sheets: [
  #   {
  #     item_headers: [],
  #     item_contents: []
  #   },
  #   {
  #     item_headers: [],
  #     item_contents: []
  #   }
  #   .
  #   .
  #   .
  #   .
  #
  # ]
  class Exporter::Spreadsheet < Exporter::BaseSuccessPresenter
    attr_accessor :headers, :contents, :template, :sheets

    def init
      super
      self.template = params[:template] || xls_template
      self.headers = params[:headers]
      self.contents = params[:contents]
      self.sheets = params[:sheets]
    end

    def render(controller)
      controller.respond_to do |format|
        format.csv {render_csv controller}
        format.xls {render_xls controller}
      end
    end

    # Handle XLS START
    def render_xls(controller)
      controller.render template, locals: binding_params
    end

    def generate_xls
      view = ActionView::Base.new(ActionController::Base.view_paths)
      view.extend ApplicationHelper
      view.render(file: "#{self.template}.xls.erb", locals: binding_params)
    end

    def xls_template
      params[:template] || 'export_template/template'
    end

    def binding_params
      # if sheets.present?
      #   sheets
      # else
      #   [{item_headers: self.headers, item_contents: self.contents, data: self.params[:data]}]
      # end
      {item_headers: self.headers, item_contents: self.contents, data: self.params[:data], sheets: self.sheets}
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

  class Exporter::AsZip < Exporter::BaseSuccessPresenter
    attr_accessor :name, :files

    def init
      super
      self.name = params[:name]
      self.files = params[:files]
    end

    def render(controller)
      controller.respond_to do |format|
        format.zip {render_zip controller}
      end
    end

    def render_zip(controller)
      result = generate_zip
      self.filename = 'finly_export' if self.filename.blank?
      self.filename += '.zip' unless self.filename.include? '.zip'
      controller.send_data result, filename: self.filename
    end

    def generate_zip
      self.files = [] if self.files.blank?
      zip_buffer = Zip::OutputStream.write_buffer do |stream|
        self.files.each do |file_details|
          dir_path = file_details[:dir_path].present? ? "#{file_details[:dir_path]}/#{file_details[:name]}" : file_details[:name]
          raise 'Invalid data format' if not file_details.is_a?(Hash) or file_details[:name].blank? or
              (file_details[:path].blank? and file_details[:file_contents].blank? and file_details[:url].blank?)
          stream.put_next_entry(dir_path)
          if file_details[:path].present?
            stream.write IO.read(file_details[:path])
          elsif file_details[:file_contents].present?
            stream.write file_details[:file_contents]
          elsif file_details[:url].present?
            stream.write(open(file_details[:url]).read)
          end

        end
      end
      zip_buffer&.string
    end

  end

  # NOTE: THIS CAN BE USED INDEPENDENTLY. I.E THIS CAN BE INSTANTIATED AND USED like in the example below
  # Usage
  # Example: Exporter::Pdf.new(user, {template: 'report.xml.erb', filename: 'assign_card', local_variables: {report: self.report}}, messages)
  class Exporter::Xml < Exporter::BaseSuccessPresenter
    attr_accessor :template, :local_variables

    def init
      super
      self.template = params[:template]
      self.local_variables = params[:local_variables]
    end

    def render(controller)
      controller.respond_to do |format|
        format.xml {render_xml controller}
      end
    end

    def render_xml(controller)
      self.filename = 'export' if self.filename.blank?
      self.filename += '.xml' unless self.filename.include? '.xml'
      if self.template.blank?
        raise 'XML template not found'
        return
      end
      controller.send_data generate_xml, filename: self.filename
    end

    def generate_xml
      view = ActionView::Base.new(ActionController::Base.view_paths)
      view.extend ApplicationHelper
      view.render(file: self.template, locals: local_variables)
    end

  end
end