require "#{Rails.root}/app/operations/company/configuration/category/index"
class Mobile::V0::Configuration::CategoryController < Mobile::V0::BaseApiController
  protect_from_forgery with: :null_session

  before_action -> { finly_authorize! :mobile}


  respond_to :json

  def index
    @result = Company::Configuration::Category::Index.(current_user, params)
    @result.config[:mobile_api] = true
    respond
  end

end