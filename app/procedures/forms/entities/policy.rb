class Forms::Entities::Policy < ApplicationPolicy

  def create?
    @user.admin?
  end

  def update?
    @user.admin?
  end

  def show?
    @user.admin?
  end

  def destroy?
    @user.admin? and not @record.system_field
  end

  def get_entity_types?
    @user.admin?
  end

end