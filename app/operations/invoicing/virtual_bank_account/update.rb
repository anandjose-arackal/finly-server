# most likely not necessary, because once created it can only be marked as inactive or destroyed

class Invoicing::VirtualBankAccount::Update < Invoicing::VirtualBankAccount::Base

  attr_accessor :virtual_bank_account_params

  def init
    super
    if self.virtual_bank_account.blank?
      number = params[:virtual_bank_account][:account_number]
      op = Invoicing::VirtualBankAccount::Index.(user, params)
      self.virtual_bank_account = op.virtual_bank_accounts.find_by(account_number: number)
    end
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
    op = FinlyCollect::Update.(user,
        account_number: self.virtual_bank_account.account_number,
        maximum_amount: self.virtual_bank_account_params.dig(:maximum_amount_attributes, :value),
        minimum_transaction_amount: self.virtual_bank_account_params.dig(:minimum_transaction_amount_attributes, :value),
        maximum_transaction_amount: self.virtual_bank_account_params.dig(:maximum_transaction_amount_attributes, :value),
        exact_transaction_amount: self.virtual_bank_account_params.dig(:exact_transaction_amount_attributes, :value),
        current_account: self.virtual_bank_account_params[:current_account],
        savings_account: self.virtual_bank_account_params[:savings_account],
        allowed_transaction_count: self.virtual_bank_account_params[:allowed_transaction_count],
        neft: self.virtual_bank_account_params[:neft],
        imps: self.virtual_bank_account_params[:imps],
        rtgs: self.virtual_bank_account_params[:rtgs],
        upi: self.virtual_bank_account_params[:upi],
        date_after: self.virtual_bank_account_params[:active_after],
        date_before: self.virtual_bank_account_params[:expires_by],
        date_on: self.virtual_bank_account_params[:active_on]
    )
    if op.success?
      # i.e. if the details got updated on the collect server, update it in the application DB
      unless self.virtual_bank_account.update(virtual_bank_account_params)
        add_message :error, self.virtual_bank_account.errors.full_messages
        Event::EAlert::Create.(nil, title: 'Finly Collect Account updated in collect server but failed to update in app',
            description: "#{self.virtual_bank_account.as_json}<br><br>Errors : #{self.virtual_bank_account.errors.full_messages}",
            subject: 'Finly Collect - Failed to create account in app')
      end
    else
      add_message :error, op.messages[:error]
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