class Forms::Entities::Ops::Create < Transactions::API

  schema do
    params do
      required(:form_entity) do
        hash do
          required(:type).filled
        end
      end
    end
  end

  # schema do
  #   params do
  #     required(:form_entity) do
  #       required(:type).filled
  #     end
  #     # required(:field_type).value(included_in?: Forms::Entity::Registry.types.keys)
  #   end
  # end

  step Model(FormEntity, :new)
  step :retrieve_model

  def retrieve_model(options, params:, **)

    options[:entity_class] = Forms::Entity::Registry.types[params[:form_entity][:type]]

    # case params[:form_entity_type]
    # when "text"
    #   options['model'] = FormEntity::Text.new
    # else
    #   options['model'] = FormEntity::Text.new
    # end
    true
  end

  step Policy::Pundit(Forms::Entities::Policy, :create?)

  step Contract::Build(builder: :retrieve_contract!)

  step :check
  def check(ctx, options)
    true
  end



  step Contract::Validate(key: :form_entity)

  step Contract::Persist()

  fail :x
  def x(ctx, options)

  end

  # Removed it after renaming custom_field to system_field
  # def set_custom_field(options, params:, **)
  #   params[:custom_field] = true
  #   true
  # end

  def retrieve_contract!(options, model:, current_user:, **)
    option_validation_proc = options[:entity_class].respond_to?(:option_validation) ? options[:entity_class].option_validation : nil

    dynamic_contract = Class.new(Forms::Entities::Contracts::CustomFormEntity) do

      instance_exec &option_validation_proc if option_validation_proc.present? && option_validation_proc.class == Proc

    end

    dynamic_contract.new(model, current_user: current_user)

    # field_type = params['form_entity_type']
    #
    # #todo - pick from right source
    # if field_type == 'text'
    #   Forms::Entities::Contracts::Text.new(model, current_user: current_user)
    # end
  end
end