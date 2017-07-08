require "#{Rails.root}/app/operations/company/configuration/category/index"
class Api::V1::Configuration::CategoryController < Api::V1::BaseApiController
  protect_from_forgery with: :null_session

  before_action :doorkeeper_authorize!


  respond_to :json

  def index
    @result = Company::Configuration::Category::Index.(current_user, params)
    @result.config[:mobile_api] = true
    respond
  end

end