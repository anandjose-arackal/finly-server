class Receipt::Destroy < Receipt::Base
  attr_accessor :receipt

  def pre_validate
    if params.blank? or user.blank?
      errors << "No user or parameters present."
    end
  end

  def init
    self.receipt = user.receipts.find_by_id(params[:receipt_id])
  end

  def authorize
    unless receipt
      raise_unauthorized_exception
    end
    unless receipt.user_id == user.id
      raise_unauthorized_exception
    end
  end

  def process
    unless receipt.destroy
      errors << "DB Error. Try again."
    end
  end
end