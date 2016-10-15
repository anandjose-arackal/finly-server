require 'roo'
# todo - come back to this once you get details about the fields of speadsheet


class Card::Assign::ImportCards < Card::Assign::Base

  attr_accessor :file, :success_hash, :header

  def authorizes_user_types
    [:company_admin]
  end

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << "Invalid input. Try again."
    end
  end

  def init
    self.file = params[:file]
    self.success_hash = {}
  end

  def authorize

  end

  def validate

  end

  def process
    sheet = open_spreadsheet(file)
    self.header = sheet.row(1)
    (2..sheet.last_row).each do |i|
      row = Hash[[header, sheet.row(i)].transpose]
      row = process_row(row)
      card = Card.new(row)
      if card.save
        success_hash[i] = "success!"
      else
        success_hash[i] = card.errors.full_messages
      end
    end
  end

  private

  # generate response csv that contains whether each card was successfully imported into the system
  def generate_response_csv
    CSV.generate(headers: true) do |csv|
      sheet = open_spreadsheet(params[:file])
      headers = sheet.row(1)
      headers << "Result"
      csv << headers
      (2..sheet.last_row).each do |i|
        row = sheet.row(i)
        row << success_hash[i]
        csv << row
      end
    end
  end


  # method to open file with roo
  def open_spreadsheet(file)
    case File.extname(file.original_filename)
      when ".csv" then Roo::Csv.new(file.path)
      when ".xls" then Roo::Excel.new(file.path)
      when ".xlsx" then Roo::Excelx.new(file.path)
      else raise "Unknown file type: #{file.original_filename}"
    end
  end

  # method that adds the respective card and associted user to the db
  def process_row(row)
    # processing the various columns of the spreadsheet
    if row['Card Proxy'].present?
      row['proxy'] = row['Card Proxy']
      row.delete('Card Proxy')
    end
    if row['Ending Number'].present?
      row['ending_number'] = row['Ending Number']
      row.delete('Ending Number')
    end
    if row['Company'].present?
      company = Company.find_by(name: row['Company'])
      row['company_id'] = company.id
      row.delete('Company')
    end
    if row['User Email'].present?
      user = User.find_by(email: row['User Email'])
      row['user_id'] = user.id
      row.delete('User Email')
    end
    row
  end

end
