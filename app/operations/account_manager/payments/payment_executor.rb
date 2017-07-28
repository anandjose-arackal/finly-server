# this class will take a single payment object and executes it using the respective adapters
#
class AccountManager::Payments::PaymentExecutor < BaseOperation

  attr_accessor :payment, :payment_item, :receiving_account_adapter, :source_account_adapter

  def self.call(payment)
    self.new(payment).run
  end

  def self.call_async(payment_id)
    # define the operation to accordingly run the operation in the background

  end

  def initialize(payment)
    self.payment = payment
  end

  def init
    self.receiving_account_adapter = retrieve_adapter(payment.receiving_account)
    self.source_account_adapter = retrieve_adapter(payment.initiating_account)
  end

  def validate
    unless receiving_account_adapter.creditable_accounts.include?(payment.initiating_account_type)
      add_message :error, "You cannot credit from this account"
      payment.system_messages.build(system_message_type_id: SystemMessageType.id_for(:error),
                                    content: "You cannot credit from #{payment.initiating_account_type.to_s} to #{payment.receiving_account_type.to_s}").save
      return
    end

    unless source_account_adapter.debitable_accounts.include?(payment.receiving_account_type)
      add_message :error, "You cannot debit to this account"
      payment.system_messages.build(system_message_type_id: SystemMessageType.id_for(:error),
                                    content: "You cannot debit from #{payment.receiving_account_type.to_s} to #{payment.initiating_account_type.to_s}").save
      return
    end

    unless source_account_adapter.balance > payment.amount_value
      add_message :error, "This account does not have enough balance for this"
      payment.system_messages.build(system_message_type_id: SystemMessageType.id_for(:error),
                                    content: "Not enough funds in #{payment.initating_account_type.to_s} to initiate the transfer").save
      return
    end

    # unless source_account_adapter.eligibility(payment.receiving_account_id) > payment.amount_value
    #   add_message :error, "This account does not have the eligibility for this"
    #   payment.system_messages.build(system_message_type_id: SystemMessageType.id_for(:error),
    #                                 content: "Eligibility of #{payment.receiving_account_type.to_s} exceeded.").save
    # end

    unless [PaymentStatus.id_for(:scheduled), PaymentStatus.id_for(:pending)].include?(payment.payment_status_id)
      add_message :error, "Payment cannot be processed in this state"
      # add system message
    end
  end

  def pre_process
    # update payment to in progress
    payment.update(payment_status_id: PaymentStatus.id_for(:in_progress))
  end

  def process
    case payment.payment_type_id
      when PaymentType.id_for(:credit)
        if source_account_adapter.debit(payment.amount.value)
          unless receiving_account_adapter.credit(payment.amount.value)
            add_message :error, receiving_account_adapter.errors
          end
          # update payment if successful
          payment.update(payment_status_id: PaymentStatus.id_for(:completed))
          # payment trail creation
        else
          add_message :error, source_account_adapter.errors
          payment.update(payment_status_id: PaymentStatus.id_for(:failed))
          source_account_adapter.credit(payment.amount.value)
          # update payment
        end
      when PaymentType.id_for(:debit)
        if source_account_adapter.credit(payment.amount.value)
          unless receiving_account_adapter.debit(payment.amount.value)
            add_message :error, receiving_account_adapter.errors
          end
          # update payment if successful
          payment.update(payment_status_id: PaymentStatus.id_for(:completed))
          # payment trail creation
        else
          add_message :error, source_account_adapter.errors
          payment.update(payment_status_id: PaymentStatus.id_for(:failed))
          source_account_adapter.debit(payment.amount.value)
          # update payment
        end
      else
        # do nothing?
    end
  end

  def post_process

  end

  private

  def retrieve_adapter(account_type)
    case account_type.class.to_s
      when Card, "Card"
        # Card, for example
        return AccountManager::Cards::CardAdapter.new(account_type.id)
      when UserWallet, "UserWallet"
        # Wallet for example
        return AccountManager::Wallet::WalletAdapter.new(account_type.id)
      when YesBankCompanyAccount, "YesBankCompanyAccount"
        return AccountManager::YesBank::YesBankCompanyAccountAdapter.new(account_type.id)
      when CashOnHand, "CashOnHand"
        return AccountManager::CashOnHand::CashOnHandAdapter.new(account_type.id)
      else
        return AccountManager::Company::ItzCashCompanyBalanceAdapter.new(account_type.id)
    end
  end
end