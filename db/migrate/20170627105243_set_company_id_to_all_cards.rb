class SetCompanyIdToAllCards < ActiveRecord::Migration
  def change
    Card.all.each do |card|
      if card.company.blank?
        card.update(company_id: card.user.company_id)
      end
    end
    change_column_null :cards, :company_id, false
  end
end
