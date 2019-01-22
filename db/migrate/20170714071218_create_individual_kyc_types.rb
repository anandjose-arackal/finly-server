class CreateIndividualKycTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :individual_kyc_types do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
    IndividualKycType.seed_data
    add_column :individual_kycs, :type_id, :integer,references: 'IndividualKycType', index: true, foreign_key: true
    add_attachment :individual_kycs, :kyc_file_1
    add_attachment :individual_kycs, :kyc_file_2
    add_column :individual_kycs, :kyc_number, :string
  end
end
