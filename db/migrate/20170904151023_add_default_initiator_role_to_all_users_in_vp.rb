class AddDefaultInitiatorRoleToAllUsersInVp < ActiveRecord::Migration[4.2]
  def change
    User.all.each do |user|
      unless user.vendor_payment_initiator?
        user.role_mapping.build(user_role_id: UserRole.id_for(:initiator), purpose_id: Purpose.id_for(:vendor_payments)).save
      end
    end
  end
end
