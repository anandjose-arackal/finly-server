class AddNoteToProcuremnt < ActiveRecord::Migration[4.2]
  def change
    add_column :procurements, :note, :text
  end
end
