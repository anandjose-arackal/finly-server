class ItzCash::Debit < ItzCash::Credit

  def transaction_type
    Constants::ItzCash::TRANSACTION_TYPE_DEBIT
  end

end