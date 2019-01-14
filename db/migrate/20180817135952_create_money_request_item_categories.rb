class CreateMoneyRequestItemCategories < ActiveRecord::Migration[4.2]
  def change
    create_table :money_request_item_categories do |t|
      t.references :company, index: true, foreign_key: true, null: false
      t.string :name, null: false, index: true
      t.boolean :active, index: true, null: false, default: true

      t.timestamps null: false
    end
    add_column :money_request_items, :money_request_item_category_id, :integer
    change_column_null :money_request_items, :category_id, true
    Category.all.each do |category|
      money_request_item = MoneyRequestItemCategory.new name: category.name, company_id: category.company_id, active: category.active
      unless money_request_item.save
        raise money_request_item.errors.full_messages
      end
      MoneyRequestItem.where(category_id: category.id).update_all(money_request_item_category_id: money_request_item.id)
    end
  end
end
