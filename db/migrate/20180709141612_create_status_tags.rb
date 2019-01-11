class CreateStatusTags < ActiveRecord::Migration[4.2]
  def change
    create_table :status_tags do |t|
      t.string :name
      t.string :display_name
      t.string :description
      t.string :font_icon
      t.string :font_icon_color
      t.string :icon_path

      t.timestamps null: false
    end

    StatusTag.seed_data
  end

end
