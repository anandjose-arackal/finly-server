class ChangeExternalReferenceIdToString < ActiveRecord::Migration
  def change
    change_column :payments, :external_reference_id, :string
  end
end