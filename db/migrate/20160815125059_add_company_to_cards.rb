class AddCompanyToCards < ActiveRecord::Migration
  def change
    add_reference :cards, :company, index: true, foreign_key: true
  end
end
