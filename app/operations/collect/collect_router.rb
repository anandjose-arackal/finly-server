# this is the class that will route the virtual transaction object to the appropriate one based on purpose
# it will accept the parameters of the request an=nd store them in the
class Collect::CollectRouter < BaseOperation

  attr_accessor :virtual_account_transaction_params, :virtual_account_transaction, :purpose_id,
                :virtual_account, :trail

  def init
    self.virtual_account_transaction_params = transaction_params
    self.virtual_account = VirtualBankAccount.find_by(account_number: virtual_account_transaction_params[:beneficiary_account_number])
    if self.virtual_account.blank?
      self.trail = VirtualAccountCollectTrail.new(found_virtual_account: false, note: "Virtual Account not found")
    elsif self.virtual_account.present?
      self.purpose_id = virtual_account.purpose_id
      initiate_trail
    end
  end

  def validate
    # if self.virtual_account.blank?
    #   # update the respective trail to record that the transaction failed and move on
    #   update_account_not_found
    # end
  end

  def pre_process
    if self.virtual_account.present?
      self.virtual_account_transaction_params[:virtual_account_id] = self.virtual_account.id
    else
      # pretty much do nothing?
    end
  end

  def process
    self.virtual_account_transaction = VirtualAccountTransaction.new(self.virtual_account_transaction_params)
    if self.virtual_account_transaction.save
      if self.virtual_account.present?
        # first update the trail object to be saved with all the details currently created
        self.trail.account_transaction = self.virtual_account_transaction
        self.trail.save
        # trigger the respective background operation that will execute the payment
        # todo - change all the below ones to async calls after testing
        case self.purpose_id
          when VirtualAccountPurpose.id_for(:virtual_bank_account)
            op = Collect::VirtualAccount::Accept.call_async(self.virtual_account_transaction.id, trail_id: self.trail.id)
          when VirtualAccountPurpose.id_for(:payment_receivable)
            op = Collect::PaymentReceivable::Accept.(user, virtual_account_transaction_id: self.virtual_account_transaction.id, trail_id: self.trail.id)
            unless op.success?
              self.trail.update(note: op.messages[:error].to_sentence, update_company_balance: false, creating_payment: false)
            end
          # these three below are kinda irrelevant
          when VirtualAccountPurpose.id_for(:invoice)
            Collect::Invoice::Accept.(self.virtual_account_transaction.id)
          when VirtualAccountPurpose.id_for(:corporate_balance_reload)
            Collect::CorporateBalanceReload::BalanceReload.(self.virtual_account_transaction.id)
          when VirtualAccountPurpose.id_for(:cash_on_hand_reversal)
            Collect::CashOnHandReturn::Return.(self.virtual_account_transaction.id)
          else
            # do nothing?
        end
      else
        # update the trail object so that it now has the details of the created transaction
        self.trail.account_transaction = self.virtual_account_transaction
        self.trail.save
      end
    else
      add_message :error, virtual_account_transaction.errors.full_messages
    end
  end

  def post_process

  end

  private

  def transaction_params
    params&.permit(:beneficiary_account_number,
                   :beneficiary_account_ifsc,
                   :transfer_type,
                   :beneficiary_full_name,
                   :transfer_id,
                   :transfer_timestamp,
                   :transfer_currency,
                   :transfer_amount,
                   :remitter_account_no,
                   :remitter_account_ifsc,
                   :remitter_account_type,
                   :remitter_full_name,
                   :remitter_address,
                   :note,
                   :credited_at)
  end

  def initiate_trail
    case self.purpose_id
      when VirtualAccountPurpose.id_for(:virtual_bank_account)
        self.trail = VirtualAccountCollectTrail.new(found_virtual_account: true) # because it wouldn't come here unless the account is found
      when VirtualAccountPurpose.id_for(:payment_receivable)
        self.trail = PaymentReceivableTransactionTrail.new
        if self.virtual_account.parent.present? && self.virtual_account.parent_type == "PaymentReceivable"
          self.trail.find_payment_receivable = true
        else
          self.trail .find_payment_receivable = false
        end
      else
        # do nothing?
    end
  end

end