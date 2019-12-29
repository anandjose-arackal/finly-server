class ExportManager::Generator::Spreadsheet < ExportManager::Generator::Base
  attr_accessor :header

  type :spreadsheet

  def self.setup(master_class)
    master_class.include Helper
  end

  def self.config(master_class)
    master_class.attributes.as_json
  end

  def perform
    self.header = Header.new

    generate_rows
    file = generate_spreadsheet
    self.save_attachment file
    self.success!
    file
  end
  
  def fields
    self.params[:fields] || []
  end

  def add_field?(attribute)
    fields.blank? or fields.include?(attribute.name.to_s)
  end
  
  # Converts input records to array of Row Objects. Each row object contains a hash of the columns and values
  def generate_rows
    master.class.attributes.each do |attr|
      next unless add_field?(attr)
      next if attr.dynamic

      header.add attr.column_name
    end

    return unless master.input.present?

    index = 1
    master.input.each do |record|
      row = ExportManager::Generator::Spreadsheet::Row.new(record: record, header: header)
      master.class.attributes.each do |attribute|
        next unless add_field?(attribute)

        if attribute.dynamic
          master.send attribute.name, row, record
        else
          value = master.send attribute.name, record rescue nil
          row.add attribute.column_name, value
        end
      end
      rows << row

      self.progress_update(index)
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