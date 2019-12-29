class ExportManager::Generator::Spreadsheet::Builder
  attr_accessor :master, :processor, :header

  def initialize(processor)
    self.processor = processor
    self.master = processor.master
    self.header = Header.new
  end

  def build
    generate_rows
    file = generate_spreadsheet
    self.processor.save_attachment file
    self.processor.success!
    file
  end

  # Converts input records to array of Row Objects. Each row object contains a hash of the columns and values
  def generate_rows
    master.class.attributes.each do |attr|
      next if attr.dynamic

      header.add attr.column_name
    end

    return unless master.input.present?

    index = 1
    master.input.each do |record|
      row = Row.new(record: record, header: header)
      master.class.attributes.each do |attribute|
        if attribute.dynamic
          master.send attribute.name, row, record
        else
          value = master.send attribute.name, record rescue nil
          row.add attribute.column_name, value
        end
      end
      rows << row

      self.processor.progress_update(index)
      index += 1
    end
  end

  def generate_spreadsheet
    headers = header.list
    contents = []
    self.rows.each do |row|
      contents << row.build
    end
    exporter = Exporter::Spreadsheet.new(self.processor.user, {headers: headers, contents: contents})
    file_name = ['export', '.xls']
    file = Paperclip::Tempfile.new(file_name)
    open(file.path, 'wb') do |f|
      # case format
      # when :csv
      #   f.write exporter.generate_csv
      # when :xls
      f.write exporter.generate_xls
      # end
    end
    file
  end

  def rows
    @rows ||= []
  end

end