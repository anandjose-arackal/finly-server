class CreateBeneficiaryPayments < ActiveRecord::Migration[5.2]
  def change
    create_table :beneficiary_payments do |t|
      t.string :name
      t.references :vendor, foreign_key: {to_table: :yes_bank_vendors}, type: :int
      t.references :bank_account, foreign_key: true, type: :int
      t.references :category, foreign_key: true, type: :int
      t.references :department, foreign_key: true, type: :int
      t.integer :original_amount_id, referenes: "Amount", foreign_key: true, index: true
      t.integer :tax_amount_id, referenes: "Amount", foreign_key: true, index: true
      t.integer :payable_amount_id, referenes: "Amount", foreign_key: true, index: true
      t.boolean :inclusive_of_taxes
      t.integer :gst_type_id, references: 'GstType', index: true, foreign_key: true
      t.decimal :tax
      t.integer :tds_slab_id, references: 'TdsRatesList', foreign_key: true, index: true
      t.integer :company_id, references: "Company", index: true, foreign_key: true
      t.integer :sub_department_id, references: 'Department', foreign_key: true, index: true

      t.timestamps
    end
  end
end
