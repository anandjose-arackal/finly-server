module Forms::Generators::Filters::ApiEntityHelper
  extend ActiveSupport::Concern

  DEFAULT_OPERATORS = [] #%i(
  #     eq_any
  #     blank
  #     present
  # )
  DEFAULT_SIMPLE_FILTER ||= :eq_any

  module ClassMethods
    def operators(*list)
      @operators ||= DEFAULT_OPERATORS
      if list.present?
        @operators += list
        @operators.uniq!
      end
      @operators
    end

    def simple_filter(filter = nil)
      @simple_filter = filter if filter.present?
      @simple_filter ||= DEFAULT_SIMPLE_FILTER
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
        filter_key: entity_path,
        operators: operators,
        multiple: multiple
    }
    if self.class.consumes_choices?
      filter[:scope] = scope
    end
    filter
  end
end