class Receipt::Create < Receipt::Base

  def pre_validate
    if params.blank? or user.blank?
      errors << "No user or parameters present."
    end
  end

  def init
    self.receipt_params = create_params
  end


  def process
    self.receipt = user.receipts.build(create_params)
    unless receipt.save
      errors << "DB Error. Try again."
    end
  end

  def retrieve
    if is_success?
      return receipt
    else
      return false
    end
  end
end