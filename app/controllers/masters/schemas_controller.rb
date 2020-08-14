class Masters::SchemasController < BaseControllers::WebBase

  def create
    endpoint Masters::Schema::Ops::Create
  end

  def update
    endpoint Masters::Schema::Ops::Update
  end

  def index
    endpoint Masters::Schema::Ops::Index
  end

  def show
    endpoint Masters::Schema::Ops::Show
  end

end
