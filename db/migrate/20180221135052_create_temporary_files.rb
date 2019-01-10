class CreateTemporaryFiles < ActiveRecord::Migration[4.2]
  def change
    create_table :temporary_files do |t|
      t.attachment :file
      t.datetime :expires_on, index: true

      t.timestamps null: false
    end
  end
end
