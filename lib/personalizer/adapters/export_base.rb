class Personalizer::Adapters::ExportBase < BaseOperation

  attr_accessor :export_file_path

  def success
    operation = Exporter::Spreadsheet.new(user, {headers: self.headers, contents: self.contents}, messages)
    if  %w(xls xlsx).include?(params[:type])
      file = operation.generate_xls_file
    elsif params[:type] == 'csv'
      file = operation.generate_csv_file
    end
    # Create a temporary file to save it to s3 and provide the download link to frontend
    temp_file = TemporaryFile.create file: file, expires_on: (DateTime.now.beginning_of_day + 7.days)
    file.close
    file.unlink
    self.export_file_path = temp_file.file.url
    params[:file_url] = export_file_path
    Personalizer::Adapters::ExportBase::FilePresenter.new(user, params, messages)
  end

  class Personalizer::Adapters::ExportBase::FilePresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :file_url, :success

    def init
      self.file_url = params[:file_url]
      self.success = true
    end
  end
end