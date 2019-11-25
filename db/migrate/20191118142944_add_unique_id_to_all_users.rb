class AddUniqueIdToAllUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :user_devices, :user_finly_id, :string, length: 36, index: true
    add_column :user_ips, :user_finly_id, :string, length: 36, index: true
    add_column :user_agent_clients, :user_finly_id, :string, length: 36, index: true

    Company.all.each do |company|
      group_entity_enabled = company.group_entity_structure_enabled? && company.group_id.present?
      if group_entity_enabled
        group_company_ids = company.group.companies.pluck(:id)
      end
      company.users.where(finly_id: nil).each do |user|
        next if user.finly_id.present?

        finly_id = nil
        while finly_id.blank? or User.find_by(finly_id: finly_id).present?
          finly_id = UUIDTools::UUID.timestamp_create().to_s.upcase if finly_id.blank?
        end

        # If not a group entity
        unless group_entity_enabled and group_company_ids.present?
          user.update finly_id: finly_id
          UserDevice.where(user_id: user.id).update_all(user_finly_id: finly_id)
          UserIp.where(user_id: user.id).update_all(user_finly_id: finly_id)
          UserAgentClient.where(user_id: user.id).update_all(user_finly_id: finly_id)
          next
        end

        # If a group entity
        users = User.with_company_id(group_company_ids).with_email_or_mobile_number(user.email, user.mobile_number)
        users.update_all finly_id: finly_id

        user_ids = users.pluck(:id)
        UserDevice.where(user_id: user_ids).update_all(user_finly_id: finly_id)
        UserIp.where(user_id: user_ids).update_all(user_finly_id: finly_id)
        UserAgentClient.where(user_id: user_ids).update_all(user_finly_id: finly_id)
      end
    end
  end
end
