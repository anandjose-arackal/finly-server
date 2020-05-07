class Forms::API::Entity::Types::AutoNumber < Forms::API::Entity::Base
  register :auto_number
  hint 'Select option'

  consumes_choices!

  config :sequence

  operators :eq_any, :not_eq_all, :cont_any, :not_cont_all, :blank, :present

  contract do
    required(:config) do
      hash do
        required(:sequence) do
          hash do
            required(:prefix).filled
            required(:start_at).filled
          end
        end
      end
    end
  end
end