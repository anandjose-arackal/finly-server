module Forms
  module Definitions
    module Types
      class Text < Entity
        register :text

        option :char_limit, default: 255, validates: {numericality: { less_than_or_equal_to: 255,  only_integer: true }}
        option :regex, default: {format: "", message: ""}
        option :format, validates: {inclusion: {in: [nil, "", "text", "email", "url", "phone_number"]}}

        # # Format validation
        # validate :regex do
        #   unless value.nil?
        #
        #   end
        # end

      end
    end
  end
end
