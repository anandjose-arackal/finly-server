class CustomField::Configuration::Base < CustomField::Base
  attr_accessor :field_configuration
  
  def success
    params[:field_configuration] = self.field_configuration
    CustomField::Configuration::Base::SuccessPresenter.new(user, params)
  end

  class CustomField::Configuration::Base::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :field_configuration

    def init
      self.field_configuration = params[:field_configuration]
    end

  end
  
end