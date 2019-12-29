module ExportManager::Generator::Spreadsheet::Builder
  extend ActiveSupport::Concern

  class_methods do
    def attribute(name, column_name: nil, dynamic: false)
      attributes << ExportManager::Generator::Spreadsheet::Attribute.new({name: name, column_name: column_name, dynamic: dynamic})
    end

    def attributes
      @attributes ||= []
    end
  end

  def build(generator)
    generate_rows(generator)
    generate_spreadsheet(generator)
  end

  def header
    @header ||= ExportManager::Generator::Spreadsheet::Header.new
  end

  def fields
    self.params[:fields] || self.params['fields'] || []
  end

  def add_field?(attribute)
    puts "Params: #{params}, Field: #{fields}, attr: #{attribute.name}, add: #{(fields.blank? or fields.include?(attribute.name.to_s))}"
    fields.blank? or fields.include?(attribute.name.to_s)
  end

  # Converts input records to array of Row Objects. Each row object contains a hash of the columns and values
  def generate_rows(generator)
    self.class.attributes.each do |attr|
      next unless add_field?(attr)
      next if attr.dynamic

      header.add attr.column_name
    end

    return unless input.present?

    index = 1
    input.each do |record|
      row = ExportManager::Generator::Spreadsheet::Row.new(record: record, header: header)
      self.class.attributes.each do |attribute|
        next unless add_field?(attribute)

        if attribute.dynamic
          self.send attribute.name, row, record
        else
          value = self.send attribute.name, record rescue nil
          row.add attribute.column_name, value
        end
      end
      rows << row

      generator.progress_update(index)
      index += 1
    end
  end

  def generate_spreadsheet(generator)
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