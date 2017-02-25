# this operation updates the balances of all the users to the balance history table on the given date

class User::Balances::SetBalances < BaseOperation

  def initialize(user, params)
    self.user = user
    self.params = params
  end

  def init

  end

  def process
    params = retrieve_balances(user)
    balance_history = user.user_balance_histories.build(params)
    balance_history.save
  end

  private

  def retrieve_balances(selected_user)
    card_balance = User::PrepaidCard::Show.(selected_user, {id: selected_user.id, view: 'admin'}).balance rescue 0

    card_withdrawal = selected_user.receiving_payments.where(date: params[:date]).where(payment_type_id: [PaymentType.id_for(:debit_from_card_to_virtual_account),
                                                                                                          PaymentType.id_for(:debit_from_card_to_wallet),
                                                                                                          PaymentType.id_for(:debit_from_card_to_card)]).joins(:amount).sum(:value)
    card_withdrawal += selected_user.initiating_payments.where(date: params[:date]).where(payment_params: [PaymentType.id_for(:credit_from_card_to_card),
                                                                                                           PaymentType.id_for(:credit_from_card_to_wallet)]).joins(:amount).sum(:value)

    card_load = selected_user.receiving_payments.where(date: params[:date]).where(payment_type_id: [PaymentType.id_for(:credit_from_wallet_to_card),
                                                                                                    PaymentType.id_for(:credit_from_virtual_account_to_card),
                                                                                                    PaymentType.id_for(:credit_from_card_to_card)]).joins(:amount).sum(:value)
    card_load += selected_user.initiating_payments.where(date: params[:date]).where(payment_type_id: [PaymentType.id_for(:debit_from_wallet_to_card),
                                                                                                      PaymentType.id_for(:debit_from_card_to_card)]).joins(:amount).sum(:value)

    card_expenses = selected_user.expenses.only_card_expenses.where(date: params[:date]).joins(:amount).sum(:value)
    card_atm_withdrawal = selected_user.initiating_payments.where(receiving_user_id: selected_user.id).where(payment_type_id: PaymentType.id_for(:atm_withdrawal)).joins(:amount).sum(:value)

    finly_money_balance = selected_user.wallet.balance_value

    finly_money_load = selected_user.receiving_payments.where(date: params[:date]).where(payment_type_id: [PaymentType.id_for(:credit_from_card_to_wallet),
                                                                                                           PaymentType.id_for(:credit_from_wallet_to_wallet),
                                                                                                           PaymentType.id_for(:credit_from_virtual_account_to_wallet)]).joins(:amount).sum(:value)
    finly_money_load += selected_user.initiating_payments.where(date: params[:date]).where(payment_type_id: [PaymentType.id_for(:debit_from_card_to_wallet),
                                                                                                             PaymentType.id_for(:debit_from_wallet_to_wallet)]).joins(:amount).sum(:value)

    finly_money_withdrawal = selected_user.receiving_payments.where(date: params[:date]).where(payment_type_id: [PaymentType.id_for(:debit_from_wallet_to_wallet),
                                                                                                                 PaymentType.id_for(:debit_from_wallet_to_card),
                                                                                                                 PaymentType.id_for(:debit_from_wallet_to_virtual_account)]).joins(:amount).sum(:value)
    finly_money_withdrawal += selected_user.initiating_payments.where(date: params[:date]).where(payment_type_id: [PaymentType.id_for(:credit_from_wallet_to_card),
                                                                                                                   PaymentType.id_for(:credit_from_wallet_to_wallet)]).joins(:amount).sum(:value)

    cash_on_hand_balance = selected_user.cash_on_hand.value
    cash_on_hand_load = selected_user.receiving_payments.where(date: params[:date]).where(payment_type_id: PaymentType.id_for(:add_cash_on_hand)).joins(:amount).sum(:value)
    cash_on_hand_withdrawal = selected_user.receiving_payments.where(date: params[:date]).where(payment_type_id: PaymentType.id_for(:deduct_cash_on_hand)).joins(:amount).sum(:value)
    {company_id: selected_user.company_id,
     date: params[:date],
     card_balance_attributes: {value: card_balance, currency: Currency.first},
     card_withdrawal_attributes: {value: card_withdrawal, currency: Currency.first},
     card_load_attributes: {value: card_load, currency: Currency.first},
     card_expenses_attributes: {value: card_expenses, currency: Currency.first},
     card_atm_withdrawal_attributes: {value: card_atm_withdrawal, currency: Currency.first},
     finly_money_balance_attributes: {value: finly_money_balance, currency: Currency.first},
     finly_money_load_attributes: {value: finly_money_load, currency: Currency.first},
     finly_money_withdrawal_attributes: {value: finly_money_withdrawal, currency: Currency.first},
     cash_on_hand_balance_attributes: {value: cash_on_hand_balance, currency: Currency.first},
     cash_on_hand_load_attributes: {value: cash_on_hand_load, currency: Currency.first},
     cash_on_hand_withdrawal_attributes: {value: cash_on_hand_withdrawal, currency: Currency.first},
    }
  end
end
