class Receipt::Destroy < Receipt::Base
  attr_accessor :receipt

  def pre_validate
    if params.blank? or user.blank?
      messages[:error] << "No user or parameters present."
    end
  end

  def init
    id = (params[:receipt_id] or params[:id])
    self.receipt = user.receipts.with_id(id).first rescue nil
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
      messages[:error] << "DB Error. Try again."
    end
  end
end