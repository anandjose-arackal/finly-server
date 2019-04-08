class Procurements::Invoices::Templates::GenerateImportSample < Procurements::Invoices::Templates::Base

  attr_accessor :company, :sample_type, :headers, :content, :sheets

  def init
    self.company = user.company
  end

  def process
    self.headers = default_headers
    self.content = []
    self.sheets = [
        {
            item_headers: self.headers,
            item_contents: []
        }
    ]
    # adding Item to excel sheet
    item_headers = ["Item Number", "Description", "Rate", "HSN/SAC", "Item Code"]
    item_contents = []
    company.items.each do |item|
      item_contents << [item.item_number, item.description, item.rate, item.hsn_sac, item.item_code]
    end
    self.sheets << {
        item_headers: item_headers,
        item_contents: item_contents,
        name: "Inventory Items"
    }

  end

  def success
    self.response = Exporter.new(user, {spreadsheet: {headers: self.headers, contents: self.content, sheets: self.sheets}}, messages)
  end

  private

  def default_headers
    [
     "Description",
     "Item number",
     "Comment",
     "Item code",
     "HSN/SAC",
     "Quantity",
     "Unit of measurement",
     "Rate",
     "Discount",
     "Tax",
     "Total"
    ]
  end

end
