class Company::ExportPreferences::Base < BaseOperation

  attr_accessor :company, :preference

  def authorized_user_types
    [:company_admin]
  end

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << "User or parameters not present."
    end
  end

  def export_params
    params.require(:export).permit(:export_field_id, :name)
  end


  class Company::ExportPreferences::Base::FieldPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :field, :result

    def init
      self.field = params[:preference]
      self.result = params[:result]
    end
  end

end

