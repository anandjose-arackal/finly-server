class Forms::Definitions::Types::AutoNumber < Forms::Definitions::Entity
  register :auto_number
  hint 'Select option'

  consumes_choices!

  option :prefix
  option :start_at

  contract do
    required(:prefix).filled
    required(:start_at).filled
  end
end