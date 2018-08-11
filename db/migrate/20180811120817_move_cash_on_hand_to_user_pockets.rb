class MoveCashOnHandToUserPockets < ActiveRecord::Migration
  def change
    # this migration will create new user cash on hand pockets for all users and also migrate all the Finly Transactions,
    # Payments and all related models that are used for calculation purposes
    User.all.each do |user|
      cash_on_hand = user.cash_on_hand
      coh_balance = cash_on_hand.balance_value
      pocket = user.user_pockets.build(name: "Cash Pocket", user_pocket_type_id: UserPocketType.id_for(:cash), balance_attributes: {value: coh_balance, currency_id: 1})
      pocket.save
      # # migrating all payments
      # initiating_payment_ids = cash_on_hand.initiating_payments.pluck(:id)
      # receiving_payment_ids = cash_on_hand.receiving_payments.pluck(:id)
      # initiating_payments = Payment.where(id: initiating_payment_ids)
      # receiving_payments = Payment.where(id: receiving_payment_ids)
      #
      # initiating_payments.each do |payment|
      #   payment_new = payment.dup
      #   if payment.initiating_account_type == "CashOnHand"
      #     payment_new.initiating_account = pocket
      #   end
      #   payment_new.save
      #
      #   # updating all system messages associated with this payment
      #   system_messages = payment.system_messages
      #   system_messages.each do |system_message|
      #     system_message.update(messagable: payment_new)
      #   end
      #
      #   # updating the payment order details here as well
      #   po = payment_new.payment_order
      #   if po&.initiating_account_type == "CashOnHand"
      #     po&.update(initiating_account_type: pocket.class.name)
      #   end
      #   # updating the old payment to no longer be part of the payment order
      #   payment.update(payment_order_id: nil)
      #
      #   finly_transactions = payment.finly_transactions
      #   finly_transactions.each do |ft|
      #     ft_new = ft.dup
      #     if ft.finly_account_type == "CashOnHand"
      #       ft_new.finly_account = pocket
      #     end
      #     ft_new.payment = payment_new
      #     ft_new.save
      #   end
      # end
      #
      # receiving_payments.each do |payment|
      #   payment_new = payment.dup
      #   if payment.receiving_account_type == "CashOnHand"
      #     payment_new.receiving_account = pocket
      #   end
      #   payment_new.save
      #
      #   # updating all system messages associated with this payment
      #   system_messages = payment.system_messages
      #   system_messages.each do |system_message|
      #     system_message.update(messagable: payment_new)
      #   end
      #
      #   # updating the payment order details here as well
      #   po = payment_new.payment_order
      #   if po&.receiving_account_type == "CashOnHand"
      #     po&.update(receiving_account_type: pocket.class.name)
      #   end
      #   # updating the old payment to no longer be part of the payment order
      #   payment.update(payment_order_id: nil)
      #
      #   finly_transactions = payment.finly_transactions
      #   finly_transactions.each do |ft|
      #     ft_new = ft.dup
      #     if ft.finly_account_type == "CashOnHand"
      #       ft_new.finly_account = pocket
      #     end
      #     ft_new.payment = payment_new
      #     ft_new.save
      #   end
      # end
    end
  end
end
