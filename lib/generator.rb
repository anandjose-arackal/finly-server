class Generator

  def self.new_transaction_id
    # 'FinlyTestRefTransId1'
    'FinlyTest1'
  end

  def self.reference_id_for(account_1, account_2, amount, date = Date.today)
    SecureRandom.hex
  end

end