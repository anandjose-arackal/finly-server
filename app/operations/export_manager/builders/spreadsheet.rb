class ExportManager::Builders::Spreadsheet < ExportManager::API
  include DSL
  include MathUtil

  attr_accessor :multiple_sheet, :header

  type :spreadsheet

  def self.config
    sections = self.sections.reject { |s| s.attributes.blank? }.as_json
    config = super()
    config[:fields] = sections if config.present?
    config
  end

  def generate
    # generate_rows
    # file = generate_rows
    file = generate_spreadsheet
    if file
      save_attachment file
      success!
    else
      failure!
    end
  end

  # def rows
  #   @rows ||= []
  # end

  # def header
  #   @header ||= Header.new
  # end

  def fields
    self.params[:fields] || self.params['fields'] || []
  end

  def add_field?(attribute)
    (fields.blank? and attribute.default) or fields.include?(attribute.name.to_s)
  end

  def generate_spreadsheet
    self.header = Header.new
    self.class.attributes.each do |attr|
      next unless add_field?(attr)
      next if attr.dynamic

      self.header.add attr.column_name
    end

    return unless export_job.total_records <= 0

    file = Paperclip::Tempfile.new(file_name)
    workbook = ::WriteXLSX.new(file, strings_to_urls: false)
    worksheet = workbook.add_worksheet('Sheet 1')
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
      row.build.each_with_index do |item, column|
        worksheet.write(index, column, item)
      end

      progress_update(index)
      index += 1
    end
    self.header.list.each_with_index do |item, index|
      worksheet.write(0, index, item)
    end
    workbook.close

    file.rewind
    file
  end

  # Converts input records to array of Row Objects. Each row object contains a hash of the columns and values
  # def generate_rows
  #   self.class.attributes.each do |attr|
  #     next unless add_field?(attr)
  #     next if attr.dynamic
  #
  #     header.add attr.column_name
  #   end
  #
  #   return unless export_job.total_records <= 0
  #
  #   index = 1
  #   data.find_each do |record|
  #     update record: record
  #     row = Row.new(record: record, header: header)
  #     self.class.attributes.each do |attribute|
  #       next unless add_field?(attribute)
  #
  #       if attribute.dynamic
  #         self.send attribute.name, row, record
  #       else
  #         value = self.send attribute.name, record
  #         row.add attribute.column_name, value
  #       end
  #     end
  #     rows << row
  #
  #     progress_update(index)
  #     index += 1
  #   end
  # end

  # def generate_spreadsheet
  #   headers = header.list
  #   contents = []
  #   self.rows.each do |row|
  #     contents << row.build
  #   end
  #   exporter = Exporter::Spreadsheet.new(self.user, {headers: headers, contents: contents})
  #   file = Paperclip::Tempfile.new(file_name)
  #   open(file.path, 'wb') do |f|
  #     case format
  #     when :csv
  #       f.write exporter.generate_csv
  #     when :xls
  #       f.write exporter.generate_xls
  #     end
  #   end
  #   file
  # end

  def file_name
    case format
    when :csv
      ['export', '.csv']
    when :xls
      ['export', '.xls']
    end
  end

  def format
    params[:export_format]&.to_sym || :xls
  end

end