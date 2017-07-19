class AddSubmittedOnToIndividualKycs < ActiveRecord::Migration
  def change
    add_column :individual_kycs, :submitted_on, :datetime
  end
end
