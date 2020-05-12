# Purpose : To output a the data of the provided record in a table format for usage in mail
# Edit the template for creating a table with desired attributes
# If any element of the row is nil, the row will be ignored

class Docs::UtilityBills::Subscriptions::Mailers::TableBulk

  attr_accessor :tables, :records

  def initialize(records)
    self.records = records
    self.tables = []
  end

  def self.call(record)
    self.new(record).process
  end

  def process
    self.tables << create_table_success
    self.tables << create_table_failure
  end

  def create_table_success
    table = {
        header: {
            title: "Successful Result",
            body: ""
        },
        content: {
            thead: [],
            tbody: []
        }
    }

    thead.each do |td|
      table[:content][:thead].push(td)
    end

    tbody(filter: {key: "success", criteria: true}) && tbody(filter: {key: "success", criteria: true}).each do |row|
      table[:content][:tbody].push(row) if row.all?
    end


    table
  end

  def create_table_failure
    table = {
        header: {
            title: "Failed Result",
            body: ""
        },
        content: {
            thead: [],
            tbody: []
        }
    }

    thead.each do |td|
      table[:content][:thead].push(td)
    end

    tbody(filter: {key: "success", criteria: false}) && tbody(filter: {key: "success", criteria: false}).each do |row|
      table[:content][:tbody].push(row) if row.all?
    end


    table
  end

  def thead
    ["#", "Sequence ID", "Biller", "Created By"]
  end

  def tbody(options = {})
    data = [

    ]

    if options.dig(:filter, :key).present?
      criteria = options[:filter][:criteria] || false
      key = options[:filter][:key].to_sym
      records.filter {|record| record[key] == criteria}.each_with_index do |record, key2|
        datum = [
            "#{key2 + 1}",
            record[:sequence_id],
            record[:biller][:biller_name],
            record[:user][:name]
        ]

        data.push(datum)
      end
    else
      records.each_with_index do |record, key|
        datum = [
            "#{key + 1}",
            record[:sequence_id],
            record[:biller][:biller_name],
            record[:user][:name]
        ]

        data.push(datum)
      end
    end
    data
  end
end