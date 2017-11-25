# this operation will call the external API for creating a virtual bank account and store it in the db
# can also pass the payment receivable if the request is for a fixed amount for a particular payment receivable

class Invoicing::VirtualBankAccount::Create < Invoicing::VirtualBankAccount::Base

  attr_accessor :account_params, :purpose_id, :bank_account, :parent, :expire_by, :exact_transaction_amount,
                :virtual_bank_account_params

  def init
    self.company = user.company
    self.purpose_id = params[:purpose_id] || ::VirtualAccountPurpose.id_for(:virtual_bank_account)
    self.parent = params[:parent]
    self.virtual_bank_account_params = virtual_account_params
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

  end

  def process
    # call the operation to generate a bank account number from the dedicated server

    op = FinlyCollect::Create.(params)
    if op.success?
      bank_account_number = op.account_number
      # temporarily using a generator for this
      self.bank_account = ::VirtualBankAccount.create(account_number: bank_account_number,
                                                    ifsc: Constants::YesBank::YES_BANK_RECEIVING_IFSC,
                                                    company_id: company.id,
                                                    purpose_id: self.purpose_id,
                                                    parent: self.parent,
                                                    initiating_user: user,
                                                    description: virtual_bank_account_params[:description],
                                                    expires_by: virtual_bank_account_params[:expires_by],
                                                    name: virtual_bank_account_params[:name]
                                                    )
    else
      add_message :error, "Could not generate virtual account number, please try again later"
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
    params.require(:virtual_bank_account).permit(:name, :expires_by, :description)
  end

  def generate_random_bank_account
    "FINLY#{random_number(10)}"
  end

  def random_number(digits)
    (0...digits).map { (48 + rand(10)).chr }.join
  end

end