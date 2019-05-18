class AdminUsers::CompaniesController < BaseControllers::AdminBase

  # todo - temporary


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

  def import_lrm
    import_op = Policy::ApprovalWorkflows::Configs::ImportLevels.new(current_user, params)
    @result = import_op.run
    @response = {
      success: true,
      file_url: @result.file_url,
      messages: @result.messages
    }
    respond_to do |format|
     format.json {
       render json: @response.as_json
     }
    end
  end

  def import_data_configuration
    if params[:'data-target'].present?
      case params[:'data-target']
      when 'locations'
        @result = Admin::Companies::Locations::Import.(current_user, params)
      when 'departments'
        @result = Admin::Companies::Departments::Import.(current_user,params)
      when 'categories'
        @result = Admin::Companies::Categories::Import.(current_user,params)
      when 'cost-centers'
        @result = Admin::Companies::CostCenters::Import.(current_user,params)
      when 'tds-slab'
        @result = Admin::Companies::TdsSlabs::Import.(current_user,params)
      when 'vendors'
        @result = Admin::Companies::Vendors::Import .(current_user,params)
      when 'item-master'
        @result =  Admin::Companies::ItemMaster::Import .(current_user, params)
      when 'lrms'
        @result =  Policy::ApprovalWorkflows::Configs::ImportLevels.(current_user, params)
      when 'lurms'
        @result = Policy::ApprovalWorkflows::Configs::ImportReviewers.(current_user, params)
      when 'policy-roles'
        @result = Admin::Companies::PolicyUserRoles::Import.(current_user, params)
      when 'bank-accounts'
        @result = Admin::Companies::BankAccounts::Import.(current_user, params)
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
