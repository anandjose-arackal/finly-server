module Forms::Filters::DSL
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
    # Forms::Filters::Cell.new(self).as_json
    filter_key = field_key
    filter_key = "#{options[:prefix]}_#{filter_key}" if options[:prefix]
    filter = {
        label: label,
        hint: hint,
        type: registered_type,
        filter_key: filter_key,
        filters: filters,
        multiple: multiple
    }
    if self.class.consumes_choices?
      filter[:scope] = scope
    end
    filter
  end
end