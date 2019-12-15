class CreditNotesController < BaseControllers::WebBase
  layout :resolve_layout

  def index
    endpoint Docs::P2P::CreditNotes::Ops::Index
    respond_to do |format|
      format.json {}
    end
  end

  def show
    @op = Docs::P2P::CreditNotes::Ops::Show.(params: params, current_user: current_user)
    # endpoint Docs::P2P::CreditNotes::Ops::Create
    respond_to do |format|
      format.json {}
    end
  end

  def edit_config
    endpoint Docs::P2P::CreditNotes::Configs::Edit
    respond_to do |format|
      format.json {}
    end
  end

  def filters_config
    endpoint Docs::P2P::CreditNotes::Configs::Filters
    # @op = Docs::P2P::CreditNotes::Configs::Filters.(params: params, current_user: current_user)
    # debugger
    respond_to do |format|
      format.json {}
    end
  end

  def create
    @op = Docs::P2P::CreditNotes::Ops::Create.(params: params, current_user: current_user)
    # endpoint Docs::P2P::CreditNotes::Ops::Create
    respond_to do |format|
      format.json {}
    end
  end

  def update
    @op = Docs::P2P::CreditNotes::Ops::Update.(params: params, current_user: current_user)
    # endpoint Docs::P2P::CreditNotes::Ops::Create
    respond_to do |format|
      format.json {}
    end
  end

  def destroy
    @op = Docs::P2P::CreditNotes::Ops::Destroy.(params: params, current_user: current_user)
    # endpoint Docs::P2P::CreditNotes::Ops::Create
    respond_to do |format|
      format.json {}
    end
  end

  def review
    params[:aasm_event] = params[:type]
    endpoint Docs::P2P::CreditNotes::Ops::Review
    # @op = Docs::P2P::CreditNotes::Ops::Review.(params: params, current_user: current_user)
    respond_to do |format|
      format.json {}
    end
  end

  def actions_config
    @result = ActionsManager::Processor.(current_user, params)
    respond
  end

  private

  def resolve_layout
    case action_name
    when 'actions_config'
      'application'
    else
      'trailblazers'
    end
  end
end
