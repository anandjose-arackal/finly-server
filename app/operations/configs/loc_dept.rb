class Configs::LocDept < BaseOperation
  attr_accessor :locations, :departments, :cost_centers

  def process
    self.departments = Company::Departments::Index.(user, params).departments
    self.locations = Company::Locations::Index.(user, params).locations
    self.cost_centers = CostCenters::Index.(user, params).cost_centers
  end

  def success
    Configs::LocDept::SuccessPresenter.new(user, {departments: self.departments, locations: self.locations, cost_centers: self.cost_centers}, messages)
  end

  class Configs::LocDept::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :locations, :departments, :cost_centers

    def init
      self.locations = params[:locations]
      self.departments = params[:departments]
      self.cost_centers
    end

  end

end