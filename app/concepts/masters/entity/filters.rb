module Masters::Entity::Filters
  extend ActiveSupport::Concern

  included do
    include Forms::Generators::Filters::ApiEntityHelper
  end

end