class EventWorkflowsController < BaseControllers::WebBase

  def create
    result = EventManager::Workflows::Create.(params.permit!.as_json, {"current_user" => current_user})
    Transactions::Endpoint.new.(result) do |m|
      m.not_found {|result| head 404}
      m.unauthenticated {|result| head 401}
      m.present {|result| render json: result["representer.serializer.class"].new(result['model']), status: 200}
      # m.created         { |result| head 201, location: "#{@path}/#{result["model"].id}" }#, result["representer.serializer.class"].new(result["model"]).to_json
      # m.success         { |result| head 200, location: "#{@path}/#{result["model"].id}" }
      # m.invalid         { |result| controller.render json: result["representer.errors.class"].new(result['result.contract.default'].errors).to_json, status: 422 }

      m.created {|result| render json: {success: true}}
      m.success {|result| render json: {success: true}}
      m.invalid {|result| render json: {success: false, errors: result.errors.as_json}}
    end
  end

  def show
    result = EventManager::Workflows::Show.(params, {"current_user" => current_user})
    Transactions::Endpoint.new.(result) do |m|
      m.not_found {|result| head 404}
      m.unauthenticated {|result| head 401}
      m.present {|result| render json: result["representer.serializer.class"].new(result['model']), status: 200}
      m.created {|result| render json: {success: true}}
      m.success {|result| render json: EventManager::Workflows::Representers::Show.new(result['model']).as_json, status: 200}
      m.invalid {|result| render json: {errors: result.errors.as_json}}
    end
  end

end