class MoveCashOnHandToUserPockets < ActiveRecord::Migration[4.2]
  def change
    # this migration will create new user cash on hand pockets for all users and also migrate all the Finly Transactions,
    # Payments and all related models that are used for calculation purposes
    User.all.each do |user|
      cash_on_hand = user.cash_on_hand
      coh_balance = cash_on_hand.balance_value
      # this pocket will replace cash on hand as the default account for all transactions
      pocket = user.user_pockets.build(name: "Cash Pocket", user_pocket_type_id: UserPocketType.id_for(:cash), atm_withdrawal_pocket: true, balance_attributes: {value: coh_balance, currency_id: 1})
      pocket.save

      # # migrating all payments
      initiating_payment_ids = cash_on_hand.initiating_payments.pluck(:id)
      receiving_payment_ids = cash_on_hand.receiving_payments.pluck(:id)
      initiating_payments = Payment.where(id: initiating_payment_ids)
      receiving_payments = Payment.where(id: receiving_payment_ids)

      # updating the payment details that belonged to Cash on Hand previously
      initiating_payments.where(initiating_account_type: "CashOnHand").update_all(initiating_account_type: "UserPocket", initiating_account_id: pocket.id)

      # updating all the payment orders to the new pocket system
      po_ids = initiating_payments.pluck(:payment_order_id)
      payment_orders = PaymentOrder.where(id: po_ids)
      payment_orders.update_all(initiating_account_type: pocket.class.name)

      finly_transactions = FinlyTransaction.where(payment_id: initiating_payment_ids)
      finly_transactions.update_all(finly_account_type: "UserPocket", finly_account_id: pocket.id)



      # updating the payment details that belonged to Cash on Hand previously
      receiving_payments.where(receiving_account_type: "CashOnHand").update_all(receiving_account_type: "UserPocket", receiving_account_id: pocket.id)

      # updating all the payment orders to the new pocket system
      po_ids = receiving_payments.pluck(:payment_order_id)
      payment_orders = PaymentOrder.where(id: po_ids)
      payment_orders.update_all(receiving_account_type: pocket.class.name)

      finly_transactions = FinlyTransaction.where(payment_id: receiving_payment_ids)
      finly_transactions.update_all(finly_account_type: "UserPocket", finly_account_id: pocket.id)
    end
  end
end