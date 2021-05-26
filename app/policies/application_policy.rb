# ApplicationPolicy is an authorization framework which restricts what resources a given user is allowed to access.
#
# All permissions can be defined in one or multiple ability files and not duplicated across controllers, views, and database queries,
# keeping your permissions logic in one place for easy maintenance and testing.
#
# ApplicationPolicy primarily relies on (while not limited to) 2 data sources for authorization
# * User Roles and Permissions.
# * FeatureToggle. (defined in https://control-panel.finly.io)
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record = nil)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  def has_permission?(*permissions)
    user.has_permission?(permissions)
  end

  def feature_enabled?(feature, default)
    user.feature_toggle.enabled?(feature, default)
  end

  def self.action(name, options = {}, &block)
    define_method name do
      next false unless pre_authorize(name, options)

      instance_exec &block
    end
  end

  def pre_authorize(action, options)
    return true if options[:skip_record_authorization]
    return false if record.blank?
    return true unless record.persisted?
    return false if record.respond_to?(:company_id) and not record.company_id == user.company_id

    true
  end

end
