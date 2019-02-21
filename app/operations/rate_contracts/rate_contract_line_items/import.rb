class RateContracts::RateContractLineItems::Import < RateContracts::RateContractLineItems::Base
  attr_accessor :rate_contract, :file, :sheet, :result_hash

  def init
    self.file = params[:file]
    self.sheet = ImportUtil.open_spreadsheet(self.file)
    self.company = user.company
  end

  def validate
    (2..sheet.last_row).each do |i|
      row = sheet.row(i)
      
    end
  end

  def process
  end

  def post_process
    self.header = [
    ]
  end

  def success
  end

  def import_fields
    [:location_code,
      :item_code,
      :start_date,
      :end_date,
      :cost
    ]
  end
end