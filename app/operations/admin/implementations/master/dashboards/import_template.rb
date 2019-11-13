class Admin::Implementations::Master::Departments::ImportTemplates < Admin::Implementations::Processor::ImportTemplate

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'dashboards.import_template'
  headers(
      {
          :id => "ID",
          :name => "Name",
          :description => "Description",
          :priority => "Priority",
          :application => "App",
          :active => "Active",
          :dashboard => "Dashboard ID",
          :user_role_id => "User Role",
          :policy_id => "Policy",
          :user_id => "User",
          :destroy => "Destroy"
      }
  )

  def valid_request
  end

  def input
    []
  end

  def post_process
  end

end
