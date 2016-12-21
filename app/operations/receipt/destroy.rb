class Receipt::Destroy < Receipt::Base
  attr_accessor :receipt

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
    end
    if params.blank?
      add_message :error, 'Receipt not found'
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

  def validate
    if receipt.parent
      add_message :error, 'Receipt that is associated with an expense or report cannot be deleted.'
    end
  end

  def process
    unless receipt.destroy
      add_message :error, 'DB Error. Try again'
    end
  end

  def post_process
    add_message :success, 'Receipt deleted'
  end
end