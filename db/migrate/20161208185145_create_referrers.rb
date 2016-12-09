class CreateReferrers < ActiveRecord::Migration
  def change
    create_table :referrers do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
