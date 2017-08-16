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
    balance_history = user.user_balance_histories.find_by(date: params[:date])
    if balance_history.present?
      balance_history.update(params)
    else
      balance_history = user.user_balance_histories.build(params)
      balance_history.save
    end
  end

  private

  def retrieve_balances(selected_user)
    card_balance = ItzCash::AccountDetails.(selected_user, {card: selected_user.cards.first}).balance rescue 0

    card_withdrawal = selected_user.receiving_payments.with_date(params[:date]).debit_from_card.joins(:amount).sum(:value)
    card_withdrawal += selected_user.initiating_payments.with_date(params[:date]).credit_from_card.joins(:amount).sum(:value)

    card_load = selected_user.receiving_payments.with_date(params[:date]).credit_to_card.joins(:amount).sum(:value)
    card_load += selected_user.initiating_payments.with_date(params[:date]).debit_to_card.joins(:amount).sum(:value)

    card_expenses = selected_user.expenses.only_card_expenses.with_date(params[:date]).joins(:amount).sum(:value)
    card_atm_withdrawal = selected_user.initiating_payments.received_by_user(selected_user.id).with_date(params[:date]).atm_withdrawals.joins(:amount).sum(:value)

    finly_money_balance = selected_user.wallet.balance_value

    finly_money_load = selected_user.receiving_payments.with_date(params[:date]).credit_to_wallet.joins(:amount).sum(:value)
    finly_money_load += selected_user.initiating_payments.with_date(params[:date]).debit_to_wallet.joins(:amount).sum(:value)

    finly_money_withdrawal = selected_user.receiving_payments.with_date(params[:date]).debit_from_wallet.joins(:amount).sum(:value)
    finly_money_withdrawal += selected_user.initiating_payments.with_date(params[:date]).credit_from_wallet.joins(:amount).sum(:value)

    cash_on_hand_balance = selected_user.cash_in_hand.value
    cash_on_hand_load = selected_user.receiving_payments.with_date(params[:date]).cash_on_hand_additions.joins(:amount).sum(:value)
    cash_on_hand_withdrawal = selected_user.receiving_payments.with_date(params[:date]).cash_on_hand_deductions.joins(:amount).sum(:value)

    {
        company_id: selected_user.company_id,
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
