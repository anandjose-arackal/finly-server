# Required Params
# {receipt_id: 1, expense_data_extract: {merchant: 'merchant name', reference_id: 'reference id', timestamp: 'timestamp', expense_data_extract_source}}
class Transcriber::Receipts::DataExtract::Create < Transcriber::Receipts::DataExtract::Base
  attr_accessor :expense_data_extract_params, :expense_data_extract, :receipt

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
    self.expense_data_extract_params = expense_data_extrac_strong_params
    if self.expense_data_extract_params.present?
      self.expense_data_extract_params[:expense_data_extract_source] = ExpenseDataExtractSource.id_for(:transcriber)
    end
    self.expense_data_extract = receipt.expense_data_extract.build self.expense_data_extract_params
  end

  def validate
    if self.receipt.blank?
      add_message :error, 'Receipt not found'
      return
    end
    if self.expense_data_extract.blank?
      add_message :error, 'Invalid details'
      return
    end
    unless self.expense_data_extract.valid?
      add_message :error, self.expense_data_extract.errors.full_messages
      return
    end
  end

  def process
    self.expense_data_extract.save
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
  def expense_data_extrac_strong_params
    self.params.require(:expense_data_extract).permit(:merchant, :reference_id, :date, :datetime,
                                                 :category_id, :illegible, amount: [:value, :currency_id])
  end

end