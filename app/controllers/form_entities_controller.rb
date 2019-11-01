class FormEntitiesController < BaseControllers::WebBase

  def index
    endpoint Forms::Entity::Index,
             args: [params.to_unsafe_h, {"current_user" => current_user}] do |m|
      m.success { |result| debugger }
    end
  end


end
