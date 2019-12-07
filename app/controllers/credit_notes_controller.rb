class CreditNotesController < BaseControllers::WebBase
  layout :resolve_layout

  def index

  end

  def show

  end

  def edit_config
    endpoint Docs::P2p::CreditNotes::Configs::Edit
    respond_to do |format|
      format.json {}
    end
  end

  def filters_config
    endpoint Docs::P2p::CreditNotes::Configs::Filters
    respond_to do |format|
      format.json {}
    end
  end

  def create

  end

  def update

  end

  def destroy

  end

  def review
    params[:aasm_event] = params[:type]
    endpoint Docs::P2p::CreditNotes::Ops::Review
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
