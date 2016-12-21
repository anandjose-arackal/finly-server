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

end