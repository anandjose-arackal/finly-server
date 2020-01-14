class Admin::Implementations::Master::Departments::Export < Admin::Implementations::Processor::Export

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'dashboards.export'

  headers({
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
          })

  def valid_request

  end

  def input
    company.insight_dashboards
  end

  def id(dashboard)
    dashboard.id
  end

  def name(dashboard)
    dashboard.name
  end

  def description(dashboard)
    dashboard.description
  end

  def priority(dashboard)
    dashboard.priority
  end

  def application(dashboard)
    dashboard.application
  end

  def active(dashboard)
    dashboard.active
  end

  def dashboard(dashboard)
    dashboard.dashboard
  end

  def user_role_id(dashboard)
    UserRole.name_for(dashboard.user_role_id)
  end

  def policy_id(dashboard)
    dashboard.policy&.name
  end

  def user_id(dashboard)
    return unless dashboard.user.present?

    dashboard.user.email || dashboard.user.mobile_number
  end


  def destroy(dashboard)
  end

  def post_process
  end

end
