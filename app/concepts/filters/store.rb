# ActiveRecord concern that initializes stored filters
module Filters::Store
  extend ActiveSupport::Concern

  class_methods do
    def filter_store(field_key)
      define_method field_key do
        value = super()
        return nil unless value

        Filters::Handler.new(value)
      end
    end
  end

end