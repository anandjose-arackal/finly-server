class ExportManager::Builders::Spreadsheet < ExportManager::API
  include DSL

  type :spreadsheet

  def self.config
    sections = self.sections.reject {|s| s.attributes.blank?}.as_json
    config = super()
    config[:fields] = sections if config.present?
    config
  end

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

  def fields
    self.params[:fields] || self.params['fields'] || []
  end

  def add_field?(attribute)
    (fields.blank? and attribute.default) or fields.include?(attribute.name.to_s)
  end

  # Converts input records to array of Row Objects. Each row object contains a hash of the columns and values
  def generate_rows
    self.class.attributes.each do |attr|
      next unless add_field?(attr)
      next if attr.dynamic

      header.add attr.column_name
    end

    return unless data.present?

    index = 1
    data.each do |record|
      row = Row.new(record: record, header: header)
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