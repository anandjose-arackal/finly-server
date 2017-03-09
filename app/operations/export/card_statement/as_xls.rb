class Export::CardStatement::AsXls < Export::CardStatement::Base

  attr_accessor :transactions, :items

  def init
    super()
    self.transactions = selected_user.card_transactions.with_transaction_timestamp_range(start_date, end_date)
  end


  def process
    @column_names = headers
    @data = []
    transactions.each do |t|
      @data << ["#{t.transaction_timestamp}",
                retrieve_transaction_type(t),
                t.merchant_name,
                (t.transaction_type == "Debit") ? t.billing_amount_value : "N/A",
                (t.transaction_type == "Credit") ? t.billing_amount_value : "N/A",
                transaction_category(t),
                transaction_status(t)
      ]
    end
  end

  def success
    EmployeeStatement::Export::Base::ExportPresenter.new(user, {header: @column_names, data: @data}, messages)
  end

end