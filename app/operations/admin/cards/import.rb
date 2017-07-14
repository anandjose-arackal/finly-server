class Admin::Cards::Import < Admin::Base

  attr_accessor :file_url, :file, :result_hash

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters. please try again"
    end
  end

  def init
    self.file = params[:file]
    self.result_hash = {}
    if file.present?
      self.sheet = open_spreadsheet(file)
      self.header = sheet.row(1)
    end
  end

  def validate
    if file.nil? || sheet.nil?
      add_message :error, "No file uploaded, please attach a file and try again"
    end
  end

  def process
    (2..sheet.last_row)
  end

  private

  def import_fields
    {
        :proxy => 0,
        :company_id => 1,
        :card_program_id => 2,
        :itz_cash_card_program => 3,
        :ending_number => 4
    }
  end
end