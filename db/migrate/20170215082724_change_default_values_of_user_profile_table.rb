class ChangeDefaultValuesOfUserProfileTable < ActiveRecord::Migration[4.2]
  def change
    # changing the ability to have null of the users and user profile columns
    change_column_null :users, :first_name, true
    change_column_null :users, :last_name, true
    change_column_null :user_profiles, :address_1, true
    change_column_null :user_profiles, :address_2, true
    change_column_null :user_profiles, :city, true
    change_column_null :user_profiles, :state_id, true
    change_column_null :user_profiles, :date_of_birth, true
    change_column_null :user_profiles, :pin_code, true

    # changing the default value of the users and user profile columns
    change_column_default :users, :first_name, nil
    change_column_default :users, :last_name, nil
    change_column_default :user_profiles, :address_1, nil
    change_column_default :user_profiles, :address_2, nil
    change_column_default :user_profiles, :city, nil
    change_column_default :user_profiles, :state_id, nil
    change_column_default :user_profiles, :date_of_birth, nil
    change_column_default :user_profiles, :pin_code, nil
  end
end
