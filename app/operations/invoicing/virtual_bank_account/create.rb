# this operation will call the external API for creating a virtual bank account and store it in the db
# can also pass the payment receivable if the request is for a fixed amount for a particular payment receivable

class Invoicing::VirtualBankAccount::Create < Invoicing::VirtualBankAccount::Base

  attr_accessor :account_params, :purpose_id, :bank_account, :parent, :expire_by, :exact_transaction_amount,
                :virtual_bank_account_params, :receiving_account

  def init
    self.company = user.company
    self.purpose_id = params[:purpose_id] || ::VirtualAccountPurpose.id_for(:virtual_bank_account)
    self.parent = params[:parent]
    self.virtual_bank_account_params = virtual_account_params
    self.receiving_account = self.company.yes_bank_company_account # by default it will be the company virtual account, until the config to change that is built
  end

  def validate
    case self.purpose_id
      when ::VirtualAccountPurpose.id_for(:cash_on_hand_reversal)
        unless self.parent&.is_a?(User)
          add_message :error, "Invalid parent type"
        end
      when ::VirtualAccountPurpose.id_for(:payment_receivable)
        unless self.parent&.is_a?(PaymentReceivable)
          add_message :error, "Invalid parent type"
        end
      when ::VirtualAccountPurpose.id_for(:invoice)
        unless self.parent&.is_a(Invoice)
          add_message :error, "Invalid parent type"
        end
      else
        # in this case it's a plain old bank account creation request, so no validations?
    end
  end

  def pre_process
    # adding the details like initiating user, purpose etc. to the Virtual Bank Account
    self.virtual_bank_account_params[:initiating_user] = user
    self.virtual_bank_account_params[:parent] = self.parent
    self.virtual_bank_account_params[:purpose_id] = self.purpose_id
    self.virtual_bank_account_params[:company_id] = self.company&.id
    self.virtual_bank_account_params[:receiving_account] = self.receiving_account
    self.virtual_bank_account_params[:ifsc] = Constants::YesBank::YES_BANK_RECEIVING_IFSC
    self.virtual_bank_account_params[:application] = current_app
  end

  def process
    # call the operation to generate a bank account number from the dedicated server
    op = FinlyCollect::Create.(user, collect_api_params)
    if op.success?
      bank_account_number = op.account_number
      self.virtual_bank_account_params[:account_number] = bank_account_number
      self.bank_account = ::VirtualBankAccount.new(virtual_bank_account_params)
      unless self.bank_account.save
        add_message :error, self.bank_account.errors.full_messages
        return
      end
    else
      add_message :error, op.messages[:error]
    end
  end

  def post_process
    add_message :success, "Virtual Account Created"
  end

  def success
    params[:virtual_bank_account] = self.bank_account
    Invoicing::VirtualBankAccount::Base::VirtualAccountPresenter.new(user, params, messages)
  end

  private

  def virtual_account_params
    if params[:virtual_bank_account].present?
      params.require(:virtual_bank_account).permit(:expires_by, :description, :name, :account_number,
                                                   :neft, :imps, :rtgs, :upi, :allowed_transaction_count,
                                                   :current_account, :savings_account,
                                                   :active_after, :active_on,
                                                   maximum_amount_attributes: [:value, :currency_id],
                                                   minimum_transaction_amount_attributes: [:value, :currency_id],
                                                   maximum_transaction_amount_attributes: [:value, :currency_id],
                                                   exact_transaction_amount_attributes: [:value, :currency_id])
    else
      {}
    end
  end

  def collect_api_params
    date_before = self.parent&.expire_by || virtual_account_params[:expires_by]
    p = {
        account_number: virtual_account_params[:account_number],
        date_before: date_before,
        exact_transaction_amount: self.parent&.amount_value
    }
    p
  end

end