class CreateTemporaryFiles < ActiveRecord::Migration
  def change
    create_table :temporary_files do |t|
      t.attachment :file
      t.datetime :expires_on, index: true

      t.timestamps null: false
    end
  end
end
