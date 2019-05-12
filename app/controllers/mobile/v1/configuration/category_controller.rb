require "#{Rails.root}/app/operations/company/configuration/category/index"
class Mobile::V1::Configuration::CategoryController < Mobile::V1::BaseApiController
  protect_from_forgery with: :null_session



  respond_to :json

  def index
    @result = Company::Configuration::Category::Index.(current_user, params)
    @result.config[:mobile_api] = true
    respond
  end

end
