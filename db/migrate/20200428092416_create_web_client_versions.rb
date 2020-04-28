class CreateWebClientVersions < ActiveRecord::Migration[5.2]
  def change
    create_table :web_clients do |t|
      t.string :version

      t.timestamps null: false
    end
  end
end
