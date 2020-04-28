class CreateWebClientVersions < ActiveRecord::Migration[5.2]
  def change
    create_table :web_clients do |t|
      t.string :version
      t.datetime :deleted_at, index: true

      t.timestamps null: false, index: true
    end
  end
end
