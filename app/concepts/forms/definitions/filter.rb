module Forms
  module Definitions
    module Filter
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
          @filters ||= Forms::Definitions::Filter::DEFAULT_FILTERS
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
    end
  end
end