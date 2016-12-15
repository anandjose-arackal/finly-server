class CreateCompanyFundsLoadRequests < ActiveRecord::Migration
  def change
    create_table :company_funds_load_requests do |t|
      t.references :company, index: true, foreign_key: true
      t.integer :requested_by_user_id, :references => "user", index: true, foreign_key: true, null: false
      t.string :reference_id, null: false
      t.date :date, null: false
      t.references :amount, index: true, foreign_key: true
      t.text :remark

      t.timestamps null: false
    end
  end
end
