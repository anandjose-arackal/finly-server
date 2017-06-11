# Required Params
# {receipt_id: 1, receipt_extract: {merchant: 'merchant name', reference_id: 'reference id', timestamp: 'timestamp', receipt_extract_source}}
class Transcriber::Receipts::DataExtract::Create < Transcriber::Receipts::DataExtract::Base
  attr_accessor :receipt_extract_params, :receipt_extract, :receipt

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or (params[:id].blank? and params[:receipt_id].blank?)
      add_message :error, 'Receipt not found'
      return
    end
  end

  def init
    id = (params[:id] and params[:receipt_id])
    self.receipt = Transcriber::Receipts::Index.(user, params).receipts.find_by(id: id) rescue nil
    return if self.receipt.blank?
    self.receipt_extract_params = receipt_extract_strong_params
    if self.receipt_extract_params.present?
      self.receipt_extract_params[:receipt_extract_source] = ReceiptExtractSource.id_for(:transcriber)
    end
    self.receipt_extract = receipt.receipt_extract.build self.receipt_extract_params
  end

  def validate
    if self.receipt.blank?
      add_message :error, 'Receipt not found'
      return
    end
    if self.receipt_extract.blank?
      add_message :error, 'Invalid details'
      return
    end
    unless self.receipt_extract.valid?
      add_message :error, self.receipt_extract.errors.full_messages
      return
    end
  end

  def process
    self.receipt_extract.save
  end

  def post_process
    # Check if has potential card expense, create cash expense if no card expense present
  end

  def success
    Transcriber::Receipts::DataExtract::Create::SuccessPresenter.new(user, params, messages)
  end

  class Transcriber::Receipts::DataExtract::Create::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter

  end

  protected
  def receipt_extract_strong_params
    self.params.require(:receipt_extract).permit(:merchant, :reference_id, :date, :time,
                                                 :category_id, :illegible, amount: [:value, :currency_id])
  end

end