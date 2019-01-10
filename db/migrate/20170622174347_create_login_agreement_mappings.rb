class CreateLoginAgreementMappings < ActiveRecord::Migration[4.2]
  def change
    create_table :login_agreement_mappings do |t|
      t.references :user, index: true, foreign_key: true, null: false
      t.references :agreement, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
