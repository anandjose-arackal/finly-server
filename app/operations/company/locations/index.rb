class Company::Locations::Index < Company::Locations::Base

  attr_accessor :locations

  class Company::Locations::Index::LocationsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :locations

    def init
      self.locations = params[:locations]
    end
  end

  def user_model
    [User, AdminUser]
  end

  def validate
    if self.company.blank?
      add_message :error, "Company not found"
    end
  end

  def process
    self.locations = self.company.locations
  end

  def success
    params[:locations] = self.locations
    Company::Locations::Index::LocationsPresenter.new(user, params, messages)
  end
end