class ItzCash::Debit < ItzCash::Credit

  def merchant_type_key
    Constants::ItzCash::MERCHANT_TYPE_KEY_DEBIT
  end

  def transaction_type
    Constants::ItzCash::TRANSACTION_TYPE_DEBIT
  end

  def validate
    super()
  end

end