class FormEntitiesController < BaseControllers::WebBase
  def show
    endpoint Forms::Entities::Ops::Show
  end

  def builder_config
    endpoint Forms::Ops::BuilderConfig
  end

  def create
    @op = Forms::Entities::Ops::Create.(params: params.to_unsafe_h, current_user: current_user)
    if @op.success?
      render :show
    end
  end

  def update
    endpoint Forms::Entities::Ops::Update
    render :show
  end

  def update_entity
    # endpoint Forms::Ops::EntityUpdate
  end

  def sync_order
    # endpoint Forms::Ops::EntitySyncOrder
  end
end
