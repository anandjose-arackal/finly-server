class AdminUsers::UsersController < BaseControllers::AdminBase
  before_action -> { finly_authorize! :admin}

  def new
    @states = State.all
  end

  def create
    @result = Admin::Users::Create.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def update
    @result = Admin::Users::Update.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def show
    @result = Admin::Users::Show.(current_user, params)
    respond
  end

  def index
    @result = Admin::Users::Index.(current_user, params)
    respond
  end

  def count
    @result = Admin::Users::Count.(current_user, params)
    render json: @result.count.as_json
  end

  # returns the respective menus that a particular user has access to
  def admin_menus
    @views = YamlUtils.load_yaml_erb("#{Rails.root}/config/data/menu_data_admin.yml.erb", {current_company: current_company, current_user: current_user})
    render json: @views.as_json
  end

  def lookup
    @result = Admin::Users::Lookup.(params)
    respond
  end

  def set_role
    @result = Admin::Users::Role::SetRole.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def update_status
    @result = Admin::Users::State::UpdateStatus.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def update_mapping
    @result = Admin::Users::Team::Mappings::Set.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def destroy_mapping
    @result = Admin::Users::Team::Mappings::Destroy.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def admin_welcome
    @result = Admin::Users::WelcomeMail.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def agreements_mail
    @result = Admin::Users::AgreementsMail.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def temp_import

  end

  def import
    import_op = Admin::Users::Import.new(current_user, params)
    @result = import_op.run
    # if @result.success?
    #   @response = {
    #       success: true,
    #       file_url: @result.file_url,
    #       messages: {
    #           error: [],
    #           failure: [],
    #           success: [],
    #           message: [],
    #           notice: []
    #       }
    #   }
    #   respond_to do |format|
    #     format.json {
    #       render json: @response.as_json
    #     }
    #   end
    # else
    #   respond response: :failure, message: @result.messages[:error]
    # end
    respond
  end

  def update_panel
    @result =  Admin::Users::Panel::Update.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def reset_password
    @result = Admin::Users::ResetPassword.(current_user, params)
    respond
  end

  private

end
