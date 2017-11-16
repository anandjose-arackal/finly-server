class AddUserPermissionForAllUsers < ActiveRecord::Migration
  def change
    User.all.each do |user|
      user.build_user_permission(company_id: user.company_id, create_beneficiaries: false).save
    end
  end
end
