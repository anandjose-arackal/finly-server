class Admin::MacrosController < BaseControllers::AdminBase
  layout 'trailblazers'

  def create
    endpoint Admin::Masters::Macros::Ops::Create
  end

  def update
    endpoint Admin::Masters::Macros::Ops::Update
  end

  def index
    endpoint Admin::Masters::Macros::Ops::Index
  end

  def show
    endpoint Admin::Masters::Macros::Ops::Show
  end

  def destroy
    endpoint Admin::Masters::Macros::Ops::Destroy
  end

end
