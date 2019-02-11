class DuplicateExistingRolesInVendorPaymentsToNewFormat < ActiveRecord::Migration[4.2]
  def change
    # by default, all users will be initiators, can be changed by the admin if he or she desires
    User.with_vendor_payments_enabled.each do |user|
      role_mappings = user.role_mapping.expense_management
      if user.role_mapping.vendor_payments.empty?
        role_mappings.each do |role_map|
          new_role_map = role_map.dup
          new_role_map.purpose_id = Purpose.id_for(:vendor_payments)
          new_role_map.save
        end
      end
    end
  end
end
