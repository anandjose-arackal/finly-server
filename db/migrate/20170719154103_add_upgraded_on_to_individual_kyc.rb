class AddUpgradedOnToIndividualKyc < ActiveRecord::Migration[4.2]
  def change
    add_column :individual_kycs, :upgraded_on, :datetime
  end
end
