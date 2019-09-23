require 'roo'
require 'saxlsx'

class ImportUtil

  JUNK_CHARACTER_LIST = %w(<html> </html> <b> </b> <u> </u> <i> </i> mailto :)

  def self.open_spreadsheet(file)
    if file.is_a?(File)
      file_name = File.extname(file)
    else
      file_name = File.extname(file.original_filename)
    end
    case file_name
      when '.csv' then
        Roo::CSV.new(file.path)
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
    return if sheet.last_row.nil?
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
        val = cleanup_account_number(key, val)
        val = cleanup_email(val)
        map[key] = val
      end
      add_line = false
      if options.present? and options[:skip_empty_lines]
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

  def self.load_spreadsheet_quickly(file, header = [], options)
    return unless header.nil? or header.is_a?(Array)

    if file.is_a?(File)
      file_name = File.extname(file)
    else
      file_name = File.extname(file.original_filename)
    end

    case file_name
    when '.xlsx' then
      # do nothing for now
    else
      raise "Please upload a '.xlsx' file. Unknown file type: #{file.original_filename}"
    end

    list = []
    Saxlsx::Workbook.open file.path do |excel|
      sheet = excel.sheets.first
      sheet.rows.each_with_index do |row, index|
        next if index == 0
        new_hash = header.zip(row).to_h
        new_hash.update(new_hash) { |key, value| val = cleanup_account_number_quickly(key, value); cleanup_email(val)}
        list << new_hash
      end
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

  def self.cleanup_email(raw_text, character_array = JUNK_CHARACTER_LIST)
    if raw_text.blank?
      return raw_text
    end
    clean_text = raw_text
    if clean_text.is_a?(Float) || clean_text.is_a?(Integer)
      clean_text = clean_text&.to_i&.to_s if clean_text.is_a?(Integer)
      clean_text = clean_text&.to_f&.to_s if clean_text.is_a?(Float)
    elsif clean_text.is_a?(Date)
      clean_text = clean_text.strftime("%d-%m-%Y")
    end
    character_array.each do |character|
      clean_text = clean_text.sub(character, '')
    end
    return clean_text
  end

  def self.cleanup_account_number(key, raw_value)
    unless key.to_s.include?("account_number")
      return raw_value
    end
    if raw_value.is_a?(Float) || raw_value.is_a?(Integer)
      raw_value.to_i.to_s
    else
      raw_value.to_s.strip
    end
  end

  def self.cleanup_account_number_quickly(key, raw_value)
    # bank account validation should happen in respective operations
    unless key.to_s.include?("account_number")
      return raw_value
    else
      raw_value = raw_value.to_s.strip
    end
  end

end