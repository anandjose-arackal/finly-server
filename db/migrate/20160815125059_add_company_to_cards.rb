class AddCompanyToCards < ActiveRecord::Migration[4.2]
  def change
    add_reference :cards, :company, index: true, foreign_key: true
  end
end
