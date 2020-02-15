class IndexSegment::Policy < ApplicationPolicy

  def create?
    owner?
  end

  def update?
    owner?
  end

  def destroy?
    owner?
  end

  def show?
    owner?
  end

  def owner?
    record.user == user
  end

end