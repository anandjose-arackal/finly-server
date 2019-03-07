class AddCreatorIdToArtifacts < ActiveRecord::Migration[5.2]
  def change
    add_column :artifacts, :creator_id, :integer
  end
end
