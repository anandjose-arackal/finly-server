class AddCardEligibilityToCards < ActiveRecord::Migration
  def change
    add_column :cards, :card_eligibility_id, :integer, references: 'Amount', foreign_key: true, index: true, null: false

    if Card.count > 0
      default_params = {value: 0, currency_id: Currency.first.id}
      Card.all.each do |card|
        save = false
        if card.card_balance_id.blank? or card.card_balance_id == 0
          balance = Amount.create(default_params)
          card.card_balance = balance
          save = true
        end
        if card.card_eligibility_id.blank? or card.card_eligibility_id == 0
          eligibility = Amount.create(default_params)
          card.card_eligibility = eligibility
          save = true
        end
        if save
          card.save
        end
      end
    end
  end
end
