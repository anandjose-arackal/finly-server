class AddUserPermissionForAllUsers < ActiveRecord::Migration[4.2]
  def change
    User.all.each do |user|
      if user.vendor_payments_admin?
        user.build_user_permission(company_id: user.company_id, create_beneficiaries: true).save
      else
        user.build_user_permission(company_id: user.company_id, create_beneficiaries: false).save
      end
    end
  end
end
