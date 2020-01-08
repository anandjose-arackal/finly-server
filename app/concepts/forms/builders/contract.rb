module Forms::Builders::Contract

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def contract(company, user)
      Forms::Builders::Contract::Build(self, company: company, user: user)
    end
  end

  def self.Build(api, company:, user:)
    raise 'Invalid company' unless company.class.name == Company.name
    raise 'Invalid user' unless user.class.name == User.name

    Build.with(api.properties, api.validations, functions: api.functions, model: api.field_class)
  end

  module Build
    def self.with(properties, validations, functions: nil, model: nil)
      klass = Class.new(Transactions::Contract)
      klass.send :model, model if model.present?
      add_functions klass, functions if functions.present?
      add_properties klass, properties
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

    def self.add_properties(klass, properties)
      properties.each do |property|
        add_property klass, property
      end
    end

    def self.add_property(klass, property)
      options = property.contract_options.dup
      type = property.contract_type
      key = property.key
      if property.properties.present?
        # NOTE:
        # Sub forms are used to define blocks
        # Ex: property amount do
        #   property :value
        # end
        # in the above example it becomes
        # property :amount, form: SubForm
        options[:form] = Build.with(property.properties, property.validations)
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