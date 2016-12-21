class ReceiptService < BaseService

  def initialize(current_user)
    super()
    @user = current_user
  end


  def create_receipt(params=nil)
    return if params.blank?
    receipt = @user.receipts.build(params)
    if receipt.save
      return receipt
    else
      errors << receipt.errors.full_messages
      return false
    end
  end

  def destroy_receipt(id=nil)
    return if id.blank?
    receipt = load_receipt id
    return unless receipt
    if receipt.destroy
      return true
    else
      errors << receipt.errors.full_messages
      return false
    end
  end

  private

  def load_receipt_params(params)
    receipt_params = params[:image]
  end

  def load_receipt(id)
    @user.receipts.find_by(id: id)
  end
end