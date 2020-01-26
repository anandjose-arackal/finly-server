module Forms::Contracts::Builder
  extend ActiveSupport::Concern

  class_methods do
    def contract(user, params = {})
      Forms::Contracts::Builder::Build(self, user: user, params: params)
    end
  end

  def self.Build(api, user:, params:)
    company = user.company
    raise 'Invalid company' unless company.class.name == Company.name
    raise 'Invalid user' unless user.class.name == User.name

    Build.with(api.entities, api.validations, functions: api.functions, model: api.field_class, params: params)
  end

  module Build
    def self.with(entities, validations, functions: nil, model: nil, params: nil)
      klass = Class.new(Transactions::Contract)
      klass.send :model, model if model.present?
      add_functions klass, functions if functions.present?
      add_entities klass, entities
      add_validations klass, validations
      klass
    end

    def self.add_functions(klass, functions)
      klass.class_eval &functions
    end

    def self.add_validations(klass, validations)
      validations.each do |type, validation_list|
        validation_list.each do |validation|
          add_validation klass, type, validation
        end
      end
    end

    def self.add_validation(klass, type, validation)
      klass.send type, *validation.args, &validation.block
    end

    def self.add_entities(klass, entities)
      entities.each do |entity|
        add_entity klass, entity
      end
    end

    def self.add_entity(klass, entity)
      options = entity.contract_options.dup
      type = entity.contract_type
      key = entity.key
      if entity.entities.present?
        # NOTE:
        # Sub forms are used to define blocks
        # Ex: entity amount do
        #   entity :value
        # end
        # in the above example it becomes
        # entity :amount, form: SubForm
        options[:form] = Build.with(entity.entities, entity.validations)
      end
      klass.send type, key, Options.new(options).reformat
    end
  end

  class Options
    attr_accessor :options, :params

    def initialize(params)
      params[:validates] = {} if params[:validates].nil?
      self.params = params.dup
      self.options = params.dup
    end

    def reformat
      options[:validates][:presence] = true if options[:required]
      options.delete(:validates) if options[:validates].blank?
      options
    end
  end

end