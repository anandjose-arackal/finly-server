class CreateCompanyConfigurations < ActiveRecord::Migration[4.2]
  def change
    create_table :contacts do |t|
      t.string :email
      t.string :name
      t.string :number

      t.timestamps null: false
    end
    create_table :company_configurations do |t|
      t.references :company, index: true, foreign_key: true, null: false
      t.references :contact, index: true, foreign_key: true
      t.boolean :verified, default: false
      t.attachment :logo

      t.timestamps null: false
    end
  end
end
