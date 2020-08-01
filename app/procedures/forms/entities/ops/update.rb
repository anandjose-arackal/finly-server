class Forms::Entities::Ops::Update < Transactions::API

  schema do
    params do
      required(:form_entity) do
        hash do
          required(:type).filled
        end
      end
    end
  end

  step Model(FormEntity, :find_by_uuid)

  step :retrieve_model_class

  def retrieve_model_class(options, params:, **)
    options[:entity_class] = Forms::Entity::Registry.types[params[:form_entity][:type]]
    true
  end

  step Policy::Pundit(Forms::Entities::Policy, :update?)

  step :check
  def check(ctx, options)
    true
  end

  step Contract::Build(builder: :build_contract!)



  step Contract::Validate(key: :form_entity)

  step Contract::Persist()

  fail :x

  def x(ctx, options)
    debugger
  end

  def build_contract!(options, model:, current_user:, **)
    base_class = model.system_field ? Forms::Entities::Contracts::SystemFormEntity : Forms::Entities::Contracts::CustomFormEntity

    option_validation_proc = options[:entity_class].respond_to?(:option_validation) ? options[:entity_class].option_validation : nil

    dynamic_contract = Class.new(base_class) do

      instance_exec &option_validation_proc if option_validation_proc.present? && option_validation_proc.class == Proc

      model.meta_attributes.each do |field|
        if model.respond_to?(field.keys.first) && model.send(field.keys.first)
          property field.values.first
        end
      end
    end

    dynamic_contract.new(model, current_user: current_user)
  end

end