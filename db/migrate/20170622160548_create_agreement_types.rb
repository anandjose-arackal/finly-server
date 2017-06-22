class CreateAgreementTypes < ActiveRecord::Migration
  def change
    create_table :agreement_types do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
    AgreementType.seed_data
  end
end
