class EmployeeStatement::Export::AsCsv < EmployeeStatement::Export::Base

  attr_accessor :transactions, :items

  def init
    super()
    self.transactions = selected_user.card_transactions.with_transaction_timestamp_range(start_date.beginning_of_day, end_date.end_of_day)
  end


  def process
    column_names = ["Date", "Transaction Type", "Merchant", "Debit Amount", "Credit Amount", "Category", "Status"]
    self.result = CSV.generate do |csv|
      csv << column_names
      transactions.each do |t|
        csv << ["#{t.transaction_timestamp}",
                retrieve_transaction_type(t),
                retrieve_merchant_name(t),
                (t.transaction_type == "Debit") ? t.billing_amount_value : "N/A",
                (t.transaction_type == "Credit") ? t.billing_amount_value : "N/A",
                transaction_category(t),
                transaction_status(t)
                ]
      end
    end
  end

  def success
    EmployeeStatement::Export::Base::ExportPresenter.new(user, {data: result}, messages)
  end

end
