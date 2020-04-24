# this class will take the API response and create the ICICI Statement model for all dates and records that don't already exist
class BankTransfer::Icici::Statement::Create < BankTransfer::Icici::Statement::Base

  attr_accessor :records, :company

  def initialize(company, records)
    self.company = company
    self.records = records
  end

  def validate
    if self.company.blank?
      add_message :error, "Company not sent in operation"
      return
    end
  end

  def process
    # need these to be sent in descending order of date
    self.records.find_each(batch_size: 10) do |record|
      transaction = self.company.icici_statements.build(
          cheque_no: record["CHEQUENO"],
          txn_date: record["TXNDATE"],
          balance: record["BALANCE"].gsub(",", ""),
          amount: record["AMOUNT"].gsub(",", ""),
          transaction_id: record["TRANSACTIONID"],
          value_date: record["VALUEDATE"],
          transaction_type: record["TYPE"],
          remarks: record["REMARKS"]
      )
      unless transaction.save
        ap transaction.errors.full_messages
      end
    end
  end

end