module Forms::Generators::Filters::DSL
  extend ActiveSupport::Concern

  DEFAULT_FILTERS = %i(
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
    def filters(*list)
      @filters ||= DEFAULT_FILTERS
      if list.present?
        @filters += list
        @filters.uniq!
      end
      @filters
    end
  end

  def filters
    self.class.filters
  end

  def filter_form(options = {})
    # Forms::Generators::Filters::Cell.new(self).as_json
    filter = {
        label: label,
        hint: hint,
        type: registered_type,
        filter_key: field_path,
        filters: filters,
        multiple: multiple
    }
    if self.class.consumes_choices?
      filter[:scope] = scope
    end
    filter
  end
end