require "#{Rails.root}/app/operations/company/configuration/category/index"
class Api::V0::Configuration::CategoryController < Api::V0::BaseApiController
  protect_from_forgery with: :null_session

  allow_oauth!
  before_action :authenticate_user!

  respond_to :json

  def index
    @result = Company::Configuration::Category::Index.(current_user, params)
    respond
  end

end