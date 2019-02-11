class DuplicateExistingMappingsInVendorPaymentsToNewFormat < ActiveRecord::Migration[4.2]
  def change
    # creating one default team mapping for all users ion vendor payment system
    User.all.each do |user|
      user.team_mapping.build(default: true, policy: user.company.policies.default.first, purpose_id: Purpose.id_for(:vendor_payments)).save
    end
  end
end
