class AddNoteToProcuremnt < ActiveRecord::Migration
  def change
    add_column :procurements, :note, :text
  end
end
