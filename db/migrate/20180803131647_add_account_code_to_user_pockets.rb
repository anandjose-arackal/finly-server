class AddAccountCodeToUserPockets < ActiveRecord::Migration[4.2]
  def change
    add_column :user_pockets, :account_code, :string

    # seeding the user_pocket_types table
    UserPocketType.seed_data
  end
end
