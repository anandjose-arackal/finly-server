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
        'Note',
    ]
    self.contents = []
    result.scoped_finly_transactions.success.sort_date_asc.all.find_each(batch_size: 10000) do |finly_transaction|
      transaction_detail = finly_transaction.transaction_detail
      credit_amount = nil
      debit_amount = nil
      if finly_transaction.credit?
        credit_amount = transaction_detail.amount.value
      else
        debit_amount = transaction_detail.amount.value
      end
      self.contents << [
          DateUtils.date_formatted(transaction_detail.transaction_date),
          transaction_detail.transaction_type.humanize,
          transaction_detail.payment_purpose.humanize,
          transaction_detail.merchant,
          credit_amount,
          debit_amount,
          transaction_detail.closing_balance&.value,
          transaction_detail.status.humanize,
          transaction_detail.transaction_reference_id,
          transaction_detail.get_note
      ]
    end
  end

  def success
    Exporter::Spreadsheet.new(user, {headers: self.headers, contents: self.contents, filename: 'statement'}, messages)
  end

end