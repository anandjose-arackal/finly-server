class AddAtmWithdrawalsFlagToUserPocket < ActiveRecord::Migration
  def change
    add_column :user_pockets, :atm_withdrawal_pocket, :boolean, default: false
  end
end
