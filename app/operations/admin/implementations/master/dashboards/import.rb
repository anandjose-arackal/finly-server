class Admin::Implementations::Master::Departments::Import < Admin::Implementations::Processor::Import

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'dashboards.import'

  headers(
      {
          :id => "ID",
          :name => "Name",
          :description => "Description",
          :priority => "Priority",
          :application => "App",
          :active => "Active",
          :dashboard => "Dashboard ID",
          :user_role => "User Role",
          :policy => "Policy",
          :user => "User",
          :destroy => "Destroy",
      }
  )

  def create_record(data)
    create_or_update(data, 'Added successfully!')
  end

  def update_record(data)
    create_or_update(data, 'Updated successfully!')
  end

  def create_or_update(data, message)
    config = data.except(:user, :policy, :user_role)
    config[:policy_id] = company.policies.non_deleted.by_name(data[:policy]).first&.id if data[:policy].present?
    config[:user_id] = company.users.where('email = ? OR mobile_number = ?', data[:user], data[:user]).first&.id if data[:user].present?
    config[:user_role_id] = UserRole.id_for(data[:user_role]&.to_sym) if data[:user_role].present?
    config[:active] = StringUtils.to_bool data[:active]
    config[:priority] = data[:priority] || 1

    if data[:id].present?
      dashboard = company.insight_dashboards.find_by id: data[:id]
      return result false, 'Record not found' unless dashboard

      dashboard.assign_attributes config
    else
      dashboard = company.insight_dashboards.build config.except(:destroy)
    end

    return result false, dashboard.errors.full_messages unless dashboard.save
    result true, message
  end

  def destroy_records(data)
    dashboard = self.company.insight_dashboards.where('id = ? OR uuid = ?', data[:id], data[:id])&.first
    return result false, "Record not found" unless dashboard

    unless dashboard.destroy
      return result false, dashboard.errors.full_messages
    end
    result true, "Destroyed Successfully"
  end
end
