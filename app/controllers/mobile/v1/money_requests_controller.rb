class Mobile::V1::MoneyRequestsController < Mobile::V1::BaseApiController
  protect_from_forgery with: :null_session

  before_action -> { finly_authorize! :mobile}


  respond_to :json

  def create
    Formatter.handle_api_nil(params)
    @result = MoneyRequests::Create.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'mobile/v1/money_requests/show'
    else
      respond response: :failure
    end
  end

  def index
    @result = MoneyRequests::Index.(current_user, params)
    @result.config[:mobile_api] = true
    respond
  end

  def show
    @result = MoneyRequests::Show.(current_user, params)
    @result.config[:mobile_api] = true
    respond render: :show
  end

  def update
    Formatter.handle_api_nil(params)
    # fail
    if params[:type].blank?
      respond_failure 'Invalid update type'
      return
    end
    case params[:type].to_sym
     when :update
        @result = MoneyRequests::Update.(current_user, params)
      when :submit
        @result = MoneyRequests::Submit.(current_user, params)
      when :retract
        @result = MoneyRequests::Retract.(current_user, params)
      when :approve
        @result = MoneyRequests::Approve.(current_user, params)
      when :reject
        @result = MoneyRequests::Reject.(current_user, params)
      when :unapprove
        @result = MoneyRequests::Unapprove.(current_user, params)
      when :credit
        # from_account: wallet / virtual_account
        @result = MoneyRequests::PrepaidCard::Credit.(current_user, params)
      when :approve_and_forward_to
        @result = MoneyRequests::ApproveAndForward.(current_user, params)
      when :take_control
        @result = MoneyRequests::TakeControl.(current_user, params)
    end
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'mobile/v1/money_requests/show'
    else
      respond response: :failure
    end
  end

  def destroy
    @result = MoneyRequests::Destroy.(current_user, params)
    @result.config[:mobile_api] = true
    respond response: :success
  end

  def comment
    if params[:content].present? and (params[:content] == "" or params[:content] == 'nil')
      params[:content] = nil
    end
    @result = MoneyRequests::Comment::Create.(current_user, params)
    @result.config[:mobile_api] = true
    if @result.success?
      respond render: 'mobile/v1/money_requests/show'
    else
      respond response: :failure
    end
  end

end
