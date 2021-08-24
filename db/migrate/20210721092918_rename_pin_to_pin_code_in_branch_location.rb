class RenamePinToPinCodeInBranchLocation < ActiveRecord::Migration[6.0]
  def change
    rename_column :branch_locations, :pin, :pin_code
  end
end
