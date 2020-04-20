class ActionManager::Validate < Transactions::API

  schema do
    params do
      required(:route).filled
      required(:record_action).filled
      optional(:record_id)
    end
  end

  step :init_route
  step :init_action
  step :authorize_action
  step :authorize_record

  def init_route(context, params:, **)
    unless ActionManager::Router.routes.include?(params[:route])
      return on_error context, :base, "Invalid route"
    end

    context[:route_klass] = ActionManager::Router[params[:route]]&.first&.klass
    return on_error context, :base, "Invalid route" unless context[:route_klass].present?

    true
  end

  def init_action(context, route_klass:, params:, **)
    context[:action] = route_klass.action_paths[params[:record_action]]
    unless context[:action]
      return on_error context, :base, "Invalid action"
    end

    true
  end

  def authorize_action(context, action:, params:, current_user:, **)
    unless current_user.has_permission?(action.permissions)
      return on_error context, :base, "Unauthorized!"
    end

    true
  end

  def authorize_record(context, route_klass:, action:, params:, current_user:, **)
    return true if params[:record_id].blank?
    return on_error context, :base, "Could not verify action" if action.model.blank? or action.policy.blank? or action.authorize.blank?

    records = action.model.where(company_id: current_user.company_id, id: params[:record_id])
    context[:records] = {processable: [], unprocessable: []}
    records.each do |record|
      policy = action.policy.new(current_user, record)
      if policy.send(action.authorize)
        context[:records][:processable] << record.id
      else
        context[:records][:unprocessable] << record.id
      end
    end

    true
  end

end