class ImportUtil

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
      when '.csv' then
        Roo::Csv.new(file.path)
      when '.xls' then
        Roo::Excel.new(file.path)
      when '.xlsx' then
        Roo::Excelx.new(file.path)
      else
        raise "Unknown file type: #{file.original_filename}"
    end
  end

  # Options
  # skip_empty_lines -> Skips lines which are completely empty
  def self.load_spreadsheet(file, header = [], options={})
    return unless header.nil? or header.is_a?(Array)

    sheet = open_spreadsheet file
    if header.blank?
      header = sheet.row(1)
    end
    header_length = header.length

    list = []
    (2..sheet.last_row).each do |i|
      row = sheet.row(i)
      map = {}
      row_length = row.length
      (0..(header_length - 1)).each do |j|
        key = header[j].to_sym
        val = nil
        unless j >= row_length
          val = row[j]
        end
        if val.present? and val.is_a?(String)
          # val.to_s.sub!('mailto:','')
        end
        map[key] = val
      end
      if options.present? and options[:skip_empty_lines]
        add_line = false
        map.each do |key, val|
          if val.present?
            add_line = true
            break
          end
        end
      end
      list << map if add_line
    end
    list
  end

  def self.generate_csv(headers, values)
    CSV.generate(headers: true) do |csv|
      csv << headers
      values.each do |i|
        csv << values[i]
      end
    end
  end

  def self.create_response_csv(header, values)


  end

end