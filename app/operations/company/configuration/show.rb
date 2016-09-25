class Company::Configuration::Show < Company::Base

  def authorized_user_types
    [:company_admin]
  end

  class Company::Configuration::Show::ShowPresenter < Company::Configuration::Show

    attr_accessor :categories, :export_fields, :export_preferences, :policies

    def initialize(user)
      self.categories = user.company.categories.active
      self.export_fields = ExportField.all
      self.export_preferences = user.company.export_preferences
      self.policies = user.company.policies.non_default.exclude_deleted
    end
  end


  def success
    Company::Configuration::Show::ShowPresenter.new(user)
  end
end