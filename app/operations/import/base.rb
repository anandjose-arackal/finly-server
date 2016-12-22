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

  def mobile_number_valid?(number)
    return "Moblie number not present" if number.blank?
    user = User.find_by(mobile_number: number)

    if user.blank?
      # checking if it's a valid mobile number
      if number.to_s =~ Constants::VALID_MOBILE_NUMBER
        return true
      else
        return "Mobile number invalid"
      end
    else
      return "Mobile number is already taken"
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