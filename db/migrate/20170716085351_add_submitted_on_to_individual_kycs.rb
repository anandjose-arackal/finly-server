class AddSubmittedOnToIndividualKycs < ActiveRecord::Migration[4.2]
  def change
    add_column :individual_kycs, :submitted_on, :datetime
  end
end
