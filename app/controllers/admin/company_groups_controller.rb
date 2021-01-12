class Admin::CompanyGroupsController < BaseControllers::AdminBase
  layout 'trailblazers'

  def create
    endpoint Admin::CompanyGroups::Ops::Create
  end

  def update
    endpoint Admin::CompanyGroups::Ops::Update
  end

  def index
    endpoint Admin::CompanyGroups::Ops::Index
  end

  def show
    endpoint Admin::CompanyGroups::Ops::Show
  end

end
