# Fixme: This is only to support the existing templates that were built using the previous structure of having
# Fixme: generate_rows and generate_spreadsheet separate.
# Fixme: This created memory leak which is why the code had to be changed.
class ExportManager::Builders::SpreadsheetOld < ExportManager::Builders::Spreadsheet

  def generate
    generate_rows
    file = generate_spreadsheet
    if file
      save_attachment file
      success!
    else
      failure!
    end
  end

  def header
    @header ||= Header.new
  end

  def rows
    @rows ||= []
  end

  # Converts input records to array of Row Objects. Each row object contains a hash of the columns and values
  def generate_rows
    self.class.attributes.each do |attr|
      next unless add_field?(attr)
      next if attr.dynamic

      header.add attr.column_name
    end

    return unless export_job.total_records <= 0

    index = 1
    data.find_each do |record|
      update record: record
      row = Row.new(record: record, header: header)
      self.class.attributes.each do |attribute|
        next unless add_field?(attribute)

        if attribute.dynamic
          self.send attribute.name, row, record
        else
          value = self.send attribute.name, record
          row.add attribute.column_name, value
        end
      end
      rows << row

      progress_update(index)
      index += 1
    end
  end

  def generate_spreadsheet
    headers = header.list
    contents = []
    self.rows.each do |row|
      contents << row.build
    end
    exporter = Exporter::Spreadsheet.new(self.user, {headers: headers, contents: contents})
    file = Paperclip::Tempfile.new(file_name)
    open(file.path, 'wb') do |f|
      case format
      when :csv
        f.write exporter.generate_csv
      when :xls
        f.write exporter.generate_xls
      end
    end
    file
  end

end