module Searchkick::DSL
  extend ActiveSupport::Concern

  included do
    include Searchkick::Api
    include searchkick_api
  end

  class_methods do
    def searchkick_api
      Object.const_get("#{self.name}Index")
    end
  end

end