class ChangeExternalReferenceIdToString < ActiveRecord::Migration[4.2]
  def change
    change_column :payments, :external_reference_id, :string
  end
end