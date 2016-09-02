class Receipt::Update < Receipt::Base
  attr_accessor :receipt

  def pre_validate
    if params.blank? or user.blank?
      errors << "No user or parameters present."
    end
  end

  def init
    params[:note] = nil if params[:note] == 'nil'
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
    unless receipt.update_attributes(update_params)
      errors << receipt.errors.full_messages
    end
  end

  private
  def update_params
    params.require(:receipt).permit(:image, :note)
  end
end