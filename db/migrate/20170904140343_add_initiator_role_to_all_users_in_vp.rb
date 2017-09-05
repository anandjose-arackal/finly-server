class AddInitiatorRoleToAllUsersInVp < ActiveRecord::Migration
  def change
    User.all.each do |user|
      unless user.vendor_payment_initiator?
        user.role_mapping.build(user_role_id: UserRole.id_for(:initiator), purpose_id: MappingPurpose.id_for(:vendor_payments))
      end
    end
  end
end
