# most likely not necessary, because once created it can only be marked as inactive or destroyed

class Invoicing::VirtualBankAccount::Update < Invoicing::VirtualBankAccount::Base

  attr_accessor :virtual_bank_account_params

  def init
    super
    self.virtual_bank_account_params = virtual_account_params
  end

  def validate
    if self.virtual_bank_account.blank?
      add_message :error, "Bank account not found"
    end
  end

  def pre_process
    # add the respective ids of the amount objects
    if self.virtual_bank_account_params[:maximum_amount_attributes].present?
      self.virtual_bank_account_params[:maximum_amount_attributes][:id] = self.virtual_bank_account.maximum_amount&.id
    end
    if self.virtual_bank_account_params[:minimum_transaction_amount_attributes].present?
      self.virtual_bank_account_params[:minimum_transaction_amount_attributes][:id] = self.virtual_bank_account.minimum_transaction_amount&.id
    end
    if self.virtual_bank_account_params[:maximum_transaction_amount_attributes].present?
      self.virtual_bank_account_params[:maximum_transaction_amount_attributes][:id] = self.virtual_bank_account.maximum_transaction_amount&.id
    end
    if self.virtual_bank_account_params[:exact_transaction_amount_attributes].present?
      self.virtual_bank_account_params[:exact_transaction_amount_attributes][:id] = self.virtual_bank_account.exact_transaction_amount&.id
    end
  end

  def process
    unless self.virtual_bank_account.update(virtual_bank_account_params)
      add_message :error, self.virtual_bank_account.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Bank Account updated"
  end

  private

  def virtual_account_params
    params.require(:virtual_bank_account).permit(:expires_by, :description, :name,
                                                 :neft, :imps, :rtgs, :upi, :allowed_transaction_count,
                                                 :current_account, :savings_account,
                                                 :active_after, :active_on,
                                                 maximum_amount_attributes: [:value, :currency_id],
                                                 minimum_transaction_amount_attributes: [:value, :currency_id],
                                                 maximum_transaction_amount_attributes: [:value, :currency_id],
                                                 exact_transaction_amount_attributes: [:value, :currency_id])
  end

end