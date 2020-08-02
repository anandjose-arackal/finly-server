class FormEntity::DropDown < FormEntity
  register :dropdown
  set :hint, 'Select value'

  operators :eq_any, :not_eq_all, :not_null, :null

  option :max_items
  option :min_items

  schema_validation do
    required(:options) do
      hash do
        optional(:min_items).value(:int?)
        optional(:min_items).value(:int?)
      end
    end
  end

  def self.option_validation
    Proc.new do
      property :choices, virtual: true

      property :choices_scope, deserializer: -> (input, represented, *args) do
        # todo - handle types other than list
        represented.choices_scope = Choices[represented.choices[:type]].(*represented.choices[:config][:choices])
      end

      validation :options_config do
        params do
          required(:choices) do
            hash do
              required(:type).value(included_in?: ["enum", "resolver", "switch", "lookup", "list"])
            end
          end
          required(:options) do
            hash do
              optional(:min_items).value(:int?)
              optional(:max_items).value(:int?)
            end
          end
        end
      end
    end
  end
end