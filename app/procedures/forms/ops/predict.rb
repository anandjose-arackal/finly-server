class Forms::Ops::Predict < Transactions::API

  schema do
    params do
      required(:route).filled #.value(included_in?: Forms::Router.map.keys)
      required(:entity_path).filled
      optional(:created_by_id).filled
      optional(:data).hash
    end
  end

  step :find_model
  step Policy::Pundit(Forms::Policy, :predict?) # Todo
  step :find_entity
  step :find_user
  step :build_ml_model
  step :predict
  step :authorize_prediction

  def find_model(context, params:, current_user:, **)
    context[:model] = Form.where.not(klass_name: nil).find_by(klass_name: Forms::Router.klass(params[:route])&.name, company_id: current_user.company_id)
    return on_error context, :base, 'Form not found' unless context[:model].present?

    true
  end

  def find_entity(context, model:, params:, **)
    context[:entity] = model.entities.find_by(entity_path: params[:entity_path])
    return on_error context, :base, 'Error in request' unless context[:entity].present?

    true
  end

  def find_user(context, params:, current_user:, **)
    if params[:created_by_id].present?
      context[:created_by] = current_user.company.users.find_by(id: params[:created_by_id])
    else
      context[:created_by] = current_user
    end

    return on_error context, :created_by, 'user not found' if context[:created_by].blank?

    true
  end

  def build_ml_model(context, entity:, **)
    context[:ml_model] = entity.prediction_model
  end

  def predict(context, ml_model:, params:, **)
    context[:prediction] = ml_model.predict(params[:data])
  end

  def authorize_prediction(context, entity:, prediction:, created_by:, **)
    if entity.choices_scope.present?
      context[:prediction] = entity.choices_scope.with_id(prediction, user: created_by).as_json.first
    end

    true
  end

end