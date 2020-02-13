module Forms::Generators::Filters::ApiEntityHelper
  extend ActiveSupport::Concern

  DEFAULT_OPERATORS = %i(
            eq
            not_eq
            cont_any
            not_cont_any
            in
            not_in
            blank
            present
        )

  module ClassMethods
    def operators(*list)
      @operators ||= DEFAULT_OPERATORS
      if list.present?
        @operators += list
        @operators.uniq!
      end
      @operators
    end
  end

  def operators
    self.class.operators
  end

  def filter_form(options = {})
    # Forms::Generators::Filters::Cell.new(self).as_json
    filter = {
        label: label,
        hint: hint,
        type: registered_type,
        filter_key: field_path,
        operators: operators,
        multiple: multiple
    }
    if self.class.consumes_choices?
      filter[:scope] = scope
    end
    filter
  end
end