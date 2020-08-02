class FormEntitiesController < BaseControllers::WebBase

  layout :resolve_layout

  def show
    endpoint Forms::Entities::Ops::Show
  end

  def builder_config
    endpoint Forms::Ops::BuilderConfig
  end

  def entity_types
    endpoint Forms::Entities::Ops::EntityTypes
  end

  def create
    @op = Forms::Entities::Ops::Create.(params: params.to_unsafe_h, current_user: current_user)
    if @op.success?
      render :show
    end
  end

  def update
    @op = Forms::Entities::Ops::Update.(params: params.to_unsafe_h, current_user: current_user)
    if @op.success?
      render :show
    end
  end

  def destroy
    endpoint Forms::Entities::Ops::Destroy
  end

  def update_entity
    # endpoint Forms::Ops::EntityUpdate
  end

  def sync_order
    # endpoint Forms::Ops::EntitySyncOrder
  end

  private

  def resolve_layout
    'trailblazers'
  end
end
