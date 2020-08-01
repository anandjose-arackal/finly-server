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
      validation :options_config do
        params do
          required(:options) do
            hash do
              optional(:min_items).value(:int?)
              optional(:min_items).value(:int?)
            end
          end
        end
      end
    end
  end
end