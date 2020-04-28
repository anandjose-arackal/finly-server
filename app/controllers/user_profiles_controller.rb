class UserProfilesController < BaseControllers::WebBase
  layout 'trailblazers'

  def update
    endpoint Masters::Users::Profile::Ops::Update
  end
end
