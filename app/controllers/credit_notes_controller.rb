class CreditNotesController < BaseControllers::WebBase
  layout :resolve_layout

  # CRUD
  def index;
    endpoint Docs::P2P::CreditNotes::Ops::Index;
  end

  def show;
    endpoint Docs::P2P::CreditNotes::Ops::Show;
  end

  def create;
    endpoint Docs::P2P::CreditNotes::Ops::Create;
  end

  def update;
    endpoint Docs::P2P::CreditNotes::Ops::Update;
  end

  def update_and_submit
    params[:id] = params[:id] || params[:_id]
    endpoint Docs::P2P::CreditNotes::Ops::UpdateAndSubmit
  end

  def destroy;
    endpoint Docs::P2P::CreditNotes::Ops::Destroy;
  end


  # Configs
  def edit_config;
    endpoint Docs::P2P::CreditNotes::Configs::Edit;
  end

  def filters_config;
    endpoint Docs::P2P::CreditNotes::Configs::Filters;
  end


  # Others
  def review;
    params[:aasm_event] = params[:type]; endpoint Docs::P2P::CreditNotes::Ops::Review;
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
