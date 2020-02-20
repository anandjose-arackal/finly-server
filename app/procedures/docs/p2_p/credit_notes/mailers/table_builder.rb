# Purpose : To output a the data of the provided record in a table format for usage in mail
# Edit the template for creating a table with desired attributes
# If any element of the row is nil, the row will be ignored

class Docs::P2P::CreditNotes::Mailers::TableBuilder

  attr_accessor :table, :record

  def initialize(record)
    self.record = record
  end

  def self.call(record)
    self.new(record).process
  end

  def process
    self.table = {
        content: {
            thead: [],
            tbody: []
        }
    }

    thead && thead.each do |row|
      self.table[:content][:thead].push(row) if row.all?
    end

    tbody && tbody.each do |row|
      self.table[:content][:tbody].push(row) if row.all?
    end


    table
  end

  def thead
  end

  def tbody
    [
        ["Credit Note Number", "#{record.sequence_id}"],
        ["Vendor", "#{record.vendor&.name} - #{record.vendor.vendor_id}"],
        ["Invoice ID", "#{record.invoice&.invoice_id}"],
        ["Invoice Number", "#{record.invoice&.invoice_number}"],
        [
            "Net Adjustable Amount",
            "#{record.net_adjustable_amount.currency.country_code} #{record.net_adjustable_amount.value}"
        ]
    ]
  end
end