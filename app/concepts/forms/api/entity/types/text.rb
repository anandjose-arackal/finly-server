class Forms::API::Entity::Types::Text < Forms::API::Entity::Base
  register :text
  hint "Enter value"

  option :char_limit, default: 255 #{numericality: {greater_than_or_equal_to: 0, less_than_or_equal_to: 255, only_integer: true}}
  option :regex #, default: {format: "", message: ""}
  option :format #, validates: {inclusion: {in: [nil, "", "text", "email", "url", "phone_number"]}}

  contract do
    required(:char_limit).value(:int?, lteq?: 255)
    optional(:regex).hash do
      required(:format).filled
      required(:message).filled
    end
    optional(:format)
  end
end