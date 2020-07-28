class FormEntitiesController < BaseControllers::WebBase



  def show
    endpoint Forms::Entities::Ops::Show
  end

  def builder_config
    endpoint Forms::Ops::BuilderConfig
  end

  def create
    endpoint Forms::Entities::Ops::Create
  end

  def update_entity
    # endpoint Forms::Ops::EntityUpdate
  end

  def sync_order
    # endpoint Forms::Ops::EntitySyncOrder
  end
end
