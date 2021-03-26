class CreateFormCurrency < ActiveRecord::Migration[6.0]
  def change
    create_table :form_currencies do |t|
      t.string :currency
      t.string :currency_code
      t.string :symbol
      t.integer :company_id, index: true, foreign_key: true, null: false, references: 'companies'
      t.timestamps null: false, index: true
    end
  end
end
