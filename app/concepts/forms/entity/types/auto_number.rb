class Forms::Entity::Types::AutoNumber < Forms::Entity::Base
  register :auto_number
  hint 'Select option'

  consumes_choices!

  option :sequence

  contract do
    required(:sequence) do
      hash do
        required(:prefix).filled
        required(:start_at).filled
      end
    end
  end
end