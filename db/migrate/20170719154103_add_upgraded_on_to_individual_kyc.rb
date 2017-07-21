class AddUpgradedOnToIndividualKyc < ActiveRecord::Migration
  def change
    add_column :individual_kycs, :upgraded_on, :datetime
  end
end
