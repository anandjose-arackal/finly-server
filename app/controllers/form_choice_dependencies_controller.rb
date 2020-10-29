class FormChoiceDependenciesController < BaseControllers::WebBase
  layout :resolve_layout

  def index
    endpoint Forms::ChoiceDependencies::Ops::Index
  end

  def show
    endpoint Forms::ChoiceDependencies::Ops::Show
  end

  def create
    endpoint Forms::ChoiceDependencies::Ops::Create
  end

  def update
    endpoint Forms::ChoiceDependencies::Ops::Update
  end

  def destroy
    endpoint Forms::ChoiceDependencies::Ops::Destroy
  end

  def enable
    # endpoint Forms::ChoiceDependencies::Ops::Enable
  end

  def disable
    # endpoint Forms::ChoiceDependencies::Ops::Disable
  end

  def resolve_layout
    'trailblazers'
  end
end