class ExportManager::Generator::Spreadsheet < ExportManager::Generator::Base

  register_format :xls, :csv

  def run
    headers = load_headers
    contents = load_contents
    exporter = Exporter::Spreadsheet.new(user, {headers: headers, contents: contents})
    file = Tempfile.new(['export', '.xls'])
    open(file.path, 'wb') do |f|
      case format
      when :csv
        f.write exporter.generate_csv
      when :xls
        f.write exporter.generate_xls
      end
    end
    temp_file = TemporaryFile.create file: file, expires_on: (DateTime.now.beginning_of_day + 7.day)
    {file_url: temp_file.file.url, success: true}
  end

  def format
    params[:export_format]&.to_sym
  end

  def file_name
    case format
    when :xls
      return 'export.xls'
    when :csv
      return 'export.csv'
    else
      nil
    end
  end

  def load_headers
    headers = []
    self.config.each do |field, conf|
      headers << (conf[:label] || field.to_s.humanize) if conf[:spreadsheet]
    end
    headers
  end

  def load_contents
    contents = []
    data = master.input
    return contents if data.nil?
    data.each do |entry|
      row = []
      self.config.each do |field, conf|
        if conf[:spreadsheet]
          if master.respond_to?(field)
            row << master.send(field, entry)
          else
            raise "#{field} not defined for exporter #{master.class.name}"
          end
        end
      end
      contents << row
    end
    contents
  end

end