class Import::Base < BaseOperation


  def generate_response_csv
    CSV.generate(headers: true) do |csv|
      self.header << "Result"
      csv << header
      (2..sheet.last_row).each do |i|
        row = sheet.row(i)
        row << result_hash[i]
        csv << row
      end
    end
  end

  def open_spreadsheet(file)
    case File.extname(file.original_filename)
      when ".csv" then Roo::Csv.new(file.path)
      when ".xls" then Roo::Excel.new(file.path)
      when ".xlsx" then Roo::Excelx.new(file.path)
      else raise "Unknown file type: #{file.original_filename}"
    end
  end

  def mobile_number_taken?(number)
    return false if number.blank?
    present = User.find_by(mobile_number: number)
    if present.blank?
      return true
    else
      return false
    end
  end

  def retrieve_invite_type(row)
    if row[import_fields[:email]].present?
      return 'email'
    elsif row[import_fields[:mobile_number]].present?
      return 'mobile'
    else
      # default case is email
      return 'email'
    end
  end

end