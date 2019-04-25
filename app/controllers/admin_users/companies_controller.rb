class AdminUsers::CompaniesController < ApplicationController

  # todo - temporary

  before_action -> { finly_authorize! :admin }

  def new
    @states = State.all
  end

  def show
    @result = Admin::Companies::Show.(current_user, params)
    respond
  end

  def create
    @result = Admin::Companies::Create.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def index
    @result = Admin::Companies::Index.(current_user, params)
    respond
  end

  def count
    @result = Admin::Companies::Count.(current_user, params)
    render json: @result.count.as_json
  end

  def update
    @result = Admin::Companies::Update.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def check_dcode
    @result = Admin::Companies::VerifyDcodeActivation.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def configure_payu
    @result = Admin::Companies::ConfigurePayu.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def company_types
    @company_types = CompanyType.all
  end

  def import_data_configuration
    if params[:'data-target'].present?
      case params[:'data-target']
      when 'locations'
          @result = Company::Locations::Import.(current_user, params)
      when 'departments'
          @result = Company::Departments::Import.(current_user,params)
      when 'categories'
          @result = Categories::Import.(current_user,params)
      when 'cost-centers'
          @result = CostCenters::Import.(current_user,params)
      when 'tds-slab'
          @result = TdsSlabs::Import.(current_user,params)
      when 'vendors'
          @result = Vendors::Import.(current_user,params)
      when 'item-master'
          @result =  ItemMaster::Item::Import.(current_user, params)
      end
    end

    if @result.success?
      @response = {
          success: true,
          file_url: @result.file_url,
          messages: {
              error: [],
              failure: [],
              success: [],
              message: [],
              notice: []
          }
      }
      respond_to do |format|
        format.json {
          render json: @response.as_json
        }
      end
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  private


end
