require "#{Rails.root}/app/models/payment"
class UpdatePaymentToIncludeAccounts < ActiveRecord::Migration
  def change
    add_column :payments, :initiating_account_id, :integer
    add_column :payments, :initiating_account_type, :string

    add_column :payments, :receiving_account_id, :integer
    add_column :payments, :receiving_account_type, :string

    if PaymentType.count > 0
      PaymentType.create id: PaymentType.id_for(:credit), name: 'Credit' if PaymentType.with_name('Credit').blank?
      PaymentType.create id: PaymentType.id_for(:debit), name: 'Debit' if PaymentType.with_name('Debit').blank?
    end

    payment_type_credit_id = PaymentType.id_for :credit
    payment_type_debit_id = PaymentType.id_for :debit
    if PaymentType.count > 0 and PaymentType.count > 0
      Payment.all.each do |payment|
        type_id = nil
        initiating_account = nil
        receiving_account = nil
        case payment.payment_type.name.to_sym
          when :credit_from_virtual_account_to_wallet
            type_id = payment_type_credit_id
            initiating_account = :virtual_account
            receiving_account = :wallet
          when :credit_from_virtual_account_to_card
            type_id = payment_type_credit_id
            initiating_account = :virtual_account
            receiving_account = :card
          when :credit_from_wallet_to_wallet
            type_id = payment_type_credit_id
            initiating_account = :wallet
            receiving_account = :wallet
          when :credit_from_wallet_to_card
            type_id = payment_type_credit_id
            initiating_account = :wallet
            receiving_account = :card
          when :credit_from_card_to_card
            type_id = payment_type_credit_id
            initiating_account = :card
            receiving_account = :card
          when :credit_from_card_to_wallet
            type_id = payment_type_credit_id
            initiating_account = :card
            receiving_account = :wallet

          when :debit_from_wallet_to_wallet
            type_id = payment_type_debit_id
            initiating_account = :wallet
            receiving_account = :wallet
          when :debit_from_wallet_to_virtual_account
            type_id = payment_type_debit_id
            initiating_account = :virtual_account
            receiving_account = :wallet
          when :debit_from_card_to_virtual_account
            type_id = payment_type_debit_id
            initiating_account= :virtual_account
            receiving_account = :card
          when :debit_from_card_to_wallet
            type_id = payment_type_debit_id
            initiating_account = :wallet
            receiving_account = :card
          when :debit_from_card_to_card
            type_id = payment_type_debit_id
            initiating_account = :card
            receiving_account = :card
          when :debit_from_wallet_to_card
            type_id = payment_type_debit_id
            initiating_account = :card
            receiving_account = :wallet
        end

        unless type_id.blank? or initiating_account.blank? or receiving_account.blank?
          initiating_account_id = nil
          initiating_account_type = nil
          case initiating_account
            when :virtual_account
              initiating_account_id = payment.initiating_user.company_id
              initiating_account_type = 'Company'
            when :wallet
              initiating_account_id = payment.initiating_user.wallet.id
              initiating_account_type = 'UserWallet'
            when :card
              initiating_account_id = payment.initiating_user.cards.first.id
              initiating_account_type = 'Card'
          end

          receiving_account_id = nil
          receiving_account_type = nil
          case receiving_account
            when :virtual_account
              receiving_account_id = payment.receiving_user.company_id
              receiving_account_type = 'Company'
            when :wallet
              receiving_account_id = payment.receiving_user.wallet.id
              receiving_account_type = 'UserWallet'
            when :card
              receiving_account_id = payment.receiving_user.cards.first.id
              receiving_account_type = 'Card'
          end
          payment.update_attributes(payment_type_id: type_id,initiating_account_id: initiating_account_id, initiating_account_type: initiating_account_type, receiving_account_id: receiving_account_id, receiving_account_type: receiving_account_type)
        end

      end
    end

    payment_items_to_destroy = []
    PaymentType.all.each do |item|
      if [:credit_from_virtual_account_to_wallet, :credit_from_virtual_account_to_card,
          :credit_from_wallet_to_wallet, :credit_from_wallet_to_card,
          :debit_from_wallet_to_wallet, :debit_from_wallet_to_virtual_account,
          :debit_from_card_to_virtual_account, :debit_from_card_to_wallet,
          :debit_from_card_to_card, :credit_from_card_to_card,
          :credit_from_card_to_wallet, :debit_from_wallet_to_card].include?(item.name.to_sym)
        payment_items_to_destroy << item.id
      end
    end
    if payment_items_to_destroy.present?
      PaymentType.all.with_id(payment_items_to_destroy).destroy_all
    end
  end

end