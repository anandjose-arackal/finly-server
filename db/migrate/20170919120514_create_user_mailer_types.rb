class CreateUserMailerTypes < ActiveRecord::Migration
  def change
    create_table :user_mailer_types do |t|
      t.string :name, null: false, index: true

      t.timestamps null: false
    end
  end
end
