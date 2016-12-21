class MoneyRequestController < ApplicationController

  def create
    @result = MoneyRequest::Create.(current_user, params)
    respond render: :show
  end

  def index
    @result = MoneyRequest::Index.(current_user, params)
    respond
  end

  def show
    @result = MoneyRequest::Show.(current_user, params)
    respond render: :show
  end

  # params[:type] = types given below
  def update
    # fail
    if params[:type].blank?
      respond_failure 'Invalid update type'
      return
    end
    case params[:type].to_sym
      when :update
        @result = MoneyRequest::Update.(current_user, params)
      when :submit
        @result = MoneyRequest::Submit.(current_user, params)
      when :retract
        @result = MoneyRequest::Retract.(current_user, params)
      when :approve
        @result = MoneyRequest::Approve.(current_user, params)
      when :reject
        @result = MoneyRequest::Reject.(current_user, params)
      when :unapprove
        @result = MoneyRequest::Unapprove.(current_user, params)
      when :credit
        # from_account: wallet / virtual_account
        @result = MoneyRequest::PrepaidCard::Credit.(current_user, params)
      when :approve_and_forward_to
        @result = MoneyRequest::ApproveAndForward.(current_user, params)
      when :take_control
        @result = MoneyRequest::TakeControl.(current_user, params)
    end
    respond render: :show
  end

  def destroy
    @result = MoneyRequest::Destroy.(current_user, params)
    respond response: :success
  end

  def comment
    @result = MoneyRequest::Comment::Create.(current_user, params)
    respond render: :show
  end

  protected
  def respond(item=nil)
    if @result.failure?
      super()
    else
      super(item)
    end
  end
end
