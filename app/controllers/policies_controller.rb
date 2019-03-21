class PoliciesController < BaseControllers::WebBase
  # protect_from_forgery with: :null_session


  def create
    @result = Policy::Create.(current_user, params)
    respond
    # redirect_to request.referrer
  end

  def destroy
    @result = Policy::Destroy.(current_user, params)
    respond
  end

  # To be used by systems where policy user role is not used
  def index
    @result = Policy::Index.(current_user, view: params[:view])
    respond
  end

  # Temporary action as exepense management is not currently using policy user roles and vendor payment is using policy based user roles
  # This action filters policy on the basis of user roles
  def index_vp
    @result = Policy::VendorPayments::Index.(current_user, params[:filter_role_id])
    respond
  end

  def show
    @result = Policy::Show.(current_user, params)
  end

  def update
    @result = Policy::Update.(current_user, params)
    respond response: (@result.success? ? :success : :failure)
  end

  def details
    policy = Policy.find(params[:id])
    respond_to do |format|
      format.json { render json: policy.as_json(:only => [:name, :id]) }
    end
  end

  def expense_rules
    @result = Policy::Show.(current_user, params)
    respond_to do |format|
      format.html { render partial: 'expense_rules' }
      format.json {}
    end
  end

  def budget_rules
    @result = Policy::Show.(current_user, params)
    respond_to do |format|
      format.html { render partial: 'budget_rules' }
      format.json {}
    end
  end

  def policy_members
    @result = Policy::Show.(current_user, params)
    respond_to do |format|
      format.html { render partial: 'policy_members' }
      format.json { }
    end
  end

  def create_rule
    @result = Policy::Show.(current_user, params)
    respond_to do |format|
      if params[:rule_category] == 'expense'
        format.html { render partial: 'create_expense_rule' }
      elsif params[:rule_category] == 'budget'
        format.html { render partial: 'create_budget_rule' }
      end
    end
  end

  def invitable_users
    @result = Policy::InvitableUsers.(current_user, params)
    respond_to do |format|
      format.html { render partial: 'users' }
      format.json { }
    end
  end

  def show_personal
    @result = Policy::Index.(current_user, params)
    respond
  end

  def show_description
    @result = Policy::Show.(current_user, params)
  end

  def policy_member_settings
    @target_user = User.find_by(id: params[:user_id])
    @result = Policy::Mappings::Show.(current_user, params)
    @mappings_policy = [@result.map]
    respond_to do |format|
      format.html { render partial: 'policy_member_settings' }
      format.json {}
    end
  end


  def add_users
    @result = Policy::Users::AddUser.(current_user, params)
    if @result.success?
      messages = @result.messages
      @result = Policy::Show.(current_user, params)
      @result.messages = messages
    end
    respond_to do |format|
      format.json {}
    end
  end

  def remove_users
    @result = Policy::Users::RemoveUser.(current_user, params)
    if @result.success?
      @result.users = Policy::Show.(current_user, params).users
      respond_to do |format|
        format.json {}
      end
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def destroy_mapping
    @result = Policy::Mappings::Destroy.(current_user, params)
    if @result.success?
      messages = @result.messages
      @result = Policy::Show.(current_user, params)
      @result.messages = messages
    end
    respond
  end


  def update_user_configuration
    @result = Policy::Users::UpdateMapping.(current_user, params)
    if @result.success?
      messages = @result.messages
      @result = Policy::Show.(current_user, params)
      @result.messages = messages
    end
    respond
  end

end
