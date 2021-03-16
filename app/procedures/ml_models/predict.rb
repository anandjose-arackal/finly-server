class MlModels::Predict < Transactions::API
  include Transactions::BackgroundWorker
  sidekiq_options queue: :payments_creation

  skip_user_authorization!

  schema do
    params do
      required(:id).filled
      optional(:data)
    end
  end

  step :load_model
  pass :predict

  def load_model(context, params:, **)
    context[:model] = self.class.cache[params[:id]] ||= MlModel.find_by(id: params[:id])
    if context[:model].blank?
      return on_error context, :model, "not found"
    end

    true
  end

  def predict(context, model:, params:, **)
    context[:prediction] = model.predict(params[:data])
  end

  def self.cache
    @cache ||= {}
  end

end