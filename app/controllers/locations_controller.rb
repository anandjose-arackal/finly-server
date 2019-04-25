class LocationsController < ApplicationController

  before_action -> { finly_authorize! :web, :admin }

  def show
    @result = Company::Locations::Show.(current_user, params)
    respond
  end

  def create
    @result = Company::Locations::Create.(current_user, params)
    respond
  end

  def update
    @result = Company::Locations::Update.(current_user, params)
    respond
  end

  def index
    @result = Company::Locations::Index.(current_user, params)
    respond
  end
end