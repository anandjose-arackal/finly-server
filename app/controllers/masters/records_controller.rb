class Masters::RecordsController < BaseControllers::WebBase

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

  # def index
  #
  # end
  #
  # def show
  #
  # end

  def destroy
    endpoint Masters::Schema::Records::Ops::Destroy
  end

end
