class AddCardStatusToCard < ActiveRecord::Migration
  def change
    if Company.count > 0
      CardStatus.seed_data
    end
    unless Card.column_names.include?('is_deleted')
      add_column :cards, :is_deleted, :boolean
    end
    # add_column :cards, :card_status_id, :integer, references: 'CardStatus', index: true, foreign_key: true
    Card.all.each do |card|
      # :assigned, :upgrade_requested, :upgraded
      acc_details = ItzCash::AccountDetails.(card.user, card: card)
      if acc_details&.success?
        balance = acc_details.balance
        eligibility = acc_details.available_card_eligibility
        if (balance + eligibility) > 25000
          card.update(card_status_id: CardStatus.id_for(:upgraded))
        elsif [KycStatus.id_for(:submitted), KycStatus.id_for(:processing)].include? card.user.individual_kyc.kyc_status_id
          card.update(card_status_id: CardStatus.id_for(:upgrade_requested))
          # todo create
        else
          card.update(card_status_id: CardStatus.id_for(:assigned))
        end
      else
        card.update(card_status_id: CardStatus.id_for(:assigned))
      end
    end
    change_column_null :cards, :card_status_id, false, 0
  end
end
