class AddingDefaultsToSqlColumns < ActiveRecord::Migration
  def change
    change_column_default :users, :first_name, ""
    change_column_default :users, :last_name, ""
    change_column_default :user_profiles, :address_1, ""
    change_column_default :user_profiles, :address_2, ""
    change_column_default :user_profiles, :date_of_birth, Date.today
    change_column_default :user_profiles, :city, ""
    change_column_default :user_profiles, :state_id, 1
    change_column_default :user_profiles, :pin_code, ""

  end
end
