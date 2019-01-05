class AddFile12ToIndividualKyc < ActiveRecord::Migration[4.2]
  def change
    add_attachment :individual_kycs, :kyc_1_front
    add_attachment :individual_kycs, :kyc_1_back
    add_attachment :individual_kycs, :kyc_2_front
    add_attachment :individual_kycs, :kyc_2_back

    add_column :individual_kycs, :kyc_1_number, :string
    add_column :individual_kycs, :kyc_2_number, :string
  end
end