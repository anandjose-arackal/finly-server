class CreatePaymentFileConfigurations < ActiveRecord::Migration
  def change
    create_table :payment_file_configurations do |t|
      t.string :file_format
      t.references :company, index: true, foreign_key: true, null: false
      t.text :options

      t.timestamps null: false
    end
  end
end
