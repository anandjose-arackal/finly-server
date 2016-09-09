require "#{Rails.root}/operations/company/configuration/category/index"
class Api::V1::Configuration::CategoryController < Api::V1::BaseApiController
  protect_from_forgery with: :null_session

  allow_oauth!
  before_action :authenticate_user!

  respond_to :json

  def index
    @result = Company::Configuration::Category::Index.(current_user, params)
  end
end