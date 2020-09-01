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
        choices = input[:choices].filter {|item| !item[:_destroy]}
        represented.choices_scope = Choices['list'].() unless represented.system_field
      end

      collection :choices, populate_if_empty: FormEntityChoice, populator: :choices! do
        property :id
        property :name
        property :company_id, deserializer: -> (input, represented, *args) {represented.company_id = represented.contract_root.current_user.company_id}
        # property :company_id, deserializer: -> (input, represented, *args) {debugger}
        property :form_id, deserializer: -> (input, represented, *args) {represented.form_id = represented.contract_root.form_id}
        property :form_section_id, deserializer: -> (input, represented, *args) {represented.form_section_id = represented.contract_root.form_section_id}
        # property :form_entity_id
        property :created_by_user_id, deserializer: -> (input, represented, *args) {represented.created_by_user_id = represented.contract_root.current_user.id}
        property :position
        property :active, deserializer: -> (input, represented, *args) {represented.active = true}
      end

      def choices!(collection:, fragment:, index:, options:, **)
        choice = choices.find {|choice| choice.id.to_s == fragment["id"].to_s}

        if fragment["_destroy"]
          choices.destroy(choice)
          return skip!
        end

        choice || choices.append(FormEntityChoice.new)
      end


      validation :options_config do
        params do
          # required(:choices) do
          #   hash do
          #     required(:type).value(included_in?: ["enum", "resolver", "switch", "lookup", "list"])
          #   end
          # end
          required(:options) do
            hash do
              optional(:min_items)
              optional(:max_items)
            end
          end
        end
        rule(:options) do
          min = value[:min_items]
          max = value[:max_items]
          key.failure("> min items can't be less than 0") if min.to_i < 0

          if min.present? && max.present?
            if min > max
              key.failure('> max items cannot be less than min items')
            end
          end
        end
      end
    end
  end
end