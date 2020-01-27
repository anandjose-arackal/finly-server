class Transactions::Contract < Reform::Form

  def add_schema_errors(errors_list)
    errors_list.to_h.each do |attr, err_list|
      # if err_list.is_a?(Hash)
      #   add_schema_errors(err_list)
      # elsif err_list.respond_to?(:each)
      #   err_list.each do |e|
      #     errors.add attr, e
      #   end
      # else
      #   errors.add attr, err_list
      # end
      errors.add attr, err_list
    end
  end

  def self.property(name, options = {}, &block)
    sanitize_options options
    super(name, options, &block)
  end

  def self.sanitize_options(options)
    return unless options.present?

    Deserializer.setup(options)
  end

  # In-case deserialize: is defined in options, it sets it up the correct way for trailblazer
  class Deserializer
    def self.setup(options)
      if options[:deserializer].present?
        unless options[:deserializer].is_a?(Hash) and options[:deserializer][:parse_pipeline].present?
          options[:deserializer] = deserialize(options[:deserializer])
        end
      end
    end

    protected

    def self.deserialize(deserializer)
      klass = self
      {
          parse_pipeline: ->(*) {
            ->(input, represented:, **) {
              if deserializer.is_a?(Symbol)
                klass.send(deserializer, input, represented, **input)
              elsif deserializer.is_a?(Class)
                # Todo
              else
                deserializer.call(input, represented, **input&.symbolize_keys)
              end
            }
          }
      }
    end
  end

  # class Transactions::Contract::Test < Transactions::Contract
  #
  #   property :name, deserializer: -> (input, represented, **) {represented.name = "a"}
  #   property :gl_code, deserializer: -> (input, represented, **) {debugger}
  #
  #   validates :name, presence: true
  #
  # end

end