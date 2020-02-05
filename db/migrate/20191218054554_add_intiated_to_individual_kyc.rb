class AddIntiatedToIndividualKyc < ActiveRecord::Migration[5.2]
  def change
    add_column :individual_kycs, :initiated, :boolean
  end
end
