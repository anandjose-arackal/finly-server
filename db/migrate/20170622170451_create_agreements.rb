class CreateAgreements < ActiveRecord::Migration
  def change
    create_table :agreements do |t|
      t.references :agreement_type, index: true, foreign_key: true, null: false
      t.attachment :file, null: false
      t.string :version, null: false
      t.boolean :active, null: false, default: false

      t.timestamps null: false
    end
  end
end
