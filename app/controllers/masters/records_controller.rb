class Masters::RecordsController < BaseControllers::WebBase
  layout 'trailblazers'

  def import
    endpoint Masters::Schema::Records::Import::Create
  end

  def import_template
    endpoint Masters::Schema::Records::Import::Template
  end

  def create
    endpoint Masters::Schema::Records::Ops::Create
  end

  def update
    endpoint Masters::Schema::Records::Ops::Update
  end

  def index
    endpoint Masters::Schema::Records::Ops::Index
  end

  def count
    endpoint Masters::Schema::Records::Ops::Count
  end

  def show
    endpoint Masters::Schema::Records::Ops::Show
  end

  def destroy
    endpoint Masters::Schema::Records::Ops::Destroy
  end

end
