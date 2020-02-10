class Company::Configuration::Show < Company::Base

  attr_accessor :purpose_id

  def authorized_user_types
    [:admin, :auditor]
  end

  def init
    super
    self.purpose_id = params[:purpose_id] || Purpose.id_from_application_for(RequestStore.store[:current_app])
  end

  class Company::Configuration::Show::ShowPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :categories, :export_fields, :export_preferences, :policies, :company,
                  :purpose_id

    def init
      self.purpose_id = params[:purpose_id]
      self.export_fields = ExportField.all.ordered_by_name
      self.export_preferences = user.company.export_preferences
      self.policies = Policy::Index.(user, params).policies rescue nil
      self.company = user.company
    end
  end


  def success
    params[:purpose_id] = self.purpose_id
    Company::Configuration::Show::ShowPresenter.new(user, params)
  end
end