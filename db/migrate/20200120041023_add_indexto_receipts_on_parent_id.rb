class AddIndextoReceiptsOnParentId < ActiveRecord::Migration[5.2]
  def change
    add_index :receipts, [:id, :user_id, :parent_id, :parent_type,:to_be_transcribed ], :name => "index_receipts_id_user_parent_parent_id"
  end
end
