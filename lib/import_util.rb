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

  def self.load_spreadsheet(file, header = [])
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
      (0..(row.length - 1)).each do |j|
        next if j >= header_length
        key = header[j].to_sym
        map[key] = row[j]
      end
      list << map
    end
    list
  end

end