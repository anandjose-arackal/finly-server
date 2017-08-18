class Statements::AsSpreadsheet < Statements::Base
  attr_accessor :headers, :contents

  def process
    result = Statements::Show.(user, params)
    unless result&.success?
      add_message :error, result.messages[:error]
      return
    end
    self.headers = [
        'Date',
        'Type',
        'Purpose',
        'Narration',
        'Credit',
        'Debit',
        'Closing Balance',
        'Status',
        'Transaction ID',
        'Note'
    ]
    self.contents = []
    result.scoped_finly_transactions.success.sort_date_asc.all.each do |finly_transaction|
      credit_amount = nil
      debit_amount = nil
      if finly_transaction.credit?
        credit_amount = finly_transaction.amount.value
      else
        debit_amount = finly_transaction.amount.value
      end
      self.contents << [
          DateUtils.date_formatted(finly_transaction.date),
          finly_transaction.transaction_type.name.humanize,
          finly_transaction.payment_purpose.name.humanize,
          result.merchant(finly_transaction),
          credit_amount,
          debit_amount,
          finly_transaction.closing_balance&.value,
          finly_transaction.status.name.humanize,
          finly_transaction.transaction_reference_id,
          nil
      ]
    end
  end

  def success
    Exporter::Spreadsheet.new(user, {headers: self.headers, contents: self.contents, filename: 'statement'}, messages)
  end

end