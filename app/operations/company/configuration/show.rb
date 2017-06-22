class Company::Configuration::Show < Company::Base

  def authorized_user_types
    [:admin]
  end

  class Company::Configuration::Show::ShowPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :categories, :export_fields, :export_preferences, :policies, :company

    def init
      self.categories = user.company.categories.active
      self.export_fields = ExportField.all
      self.export_preferences = user.company.export_preferences
      self.policies = Policy::Index.(user, params).policies rescue nil
      self.company = user.company
    end
  end


  def success
    Company::Configuration::Show::ShowPresenter.new(user, params)
  end
end