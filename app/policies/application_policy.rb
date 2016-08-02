class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def check_personal_view
    unless @user.view == 'personal' || @user.view.nil?
      return false
    end
    true
  end

  def check_admin_view
    unless @user.view == 'admin'
      return false
    end
    true
  end

  def check_manager_view
    unless @user.view == 'manager'
      return false
    end
    true
  end

  def check_finance_view
    unless @user.view == 'finance'
      return false
    end
    true
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end
  end

  private

end
