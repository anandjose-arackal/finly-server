# Purpose : To output a the data of the provided record in a table format for usage in mail
# Edit the template for creating a table with desired attributes
# If any element of the row is nil, the row will be ignored

class Docs::UtilityBills::Bills::Mailers::TableBuilder

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
        ["Biller", "#{record.biller.name}"],
        ["Name", "#{record.subscription.name}"],
        [
            "Amount",
            (record.amount.value != 0 ? "#{record.amount.currency.country_code} #{record.amount.value}" : nil)
        ],
        ["Bill Date", (record.bill_date.present? ? record.bill_date : nil)],
        ["Due Date", (record.due_date.present? ? record.due_date : nil)],
        ["Type", (record.autofetched ? "Autofetched" : "Manual")]
    ]
  end
end