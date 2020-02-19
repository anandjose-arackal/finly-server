# Purpose : To output a the data of the provided record in a table format for usage in mail
# Edit the template for creating a table with desired attributes
# If any element of the row is nil, the row will be ignored

class Docs::UtilityBills::Subscriptions::Mailers::TableBuilder

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
    data = [
        ["Title", "#{record.name}"],
        ["Department", record.department&.name],
        ["Policy", record.policy&.name],
        ["Type", record.biller&.biller_category_name],
        ["Board", record.biller&.biller_name],
        ["Bill Creation Type", (record.auto_fetchable ? "Autofetched" : "Manual")]
    ]

    record.all_customer_fields.each_with_index.map {|value, index| [value["customer_param_key_#{index + 1}"], value["customer_param_value_#{index + 1}"]]}.filter(&:any?).each do |arr|
      data.push(arr)
    end

    data
  end
end