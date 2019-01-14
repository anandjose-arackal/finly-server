class CreateDesktopUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :desktop_users do |t|
      t.string :email, null: false
      t.string :country, null: false

      t.timestamps null: false
    end
  end
end
