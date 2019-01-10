class SetCompanyIdToAllCards < ActiveRecord::Migration[4.2]
  def change
    if Company.count > 0
      Card.all.each do |card|
        if card.company.blank?
          card.update(company_id: card.user.company_id)
        end
      end
      change_column_null :cards, :company_id, false
    end
  end
end
