module Ransacker
  extend ActiveSupport::Concern

  included do
    columns_hash.each_pair do |attribute_name, properties|
      next unless properties.type == :datetime

      ransack_date attribute_name
    end
    # ransack_date :created_at
    # ransack_date :updated_at
    # ransack_date :deleted_at
    # ransack_date :submitted_at if self.attribute_names.include?("submitted_at")
    # ransack_date :approved_at if self.attribute_names.include?("approved_at")
    # ransack_date :date if self.attribute_names.include?("date")
    # ransack_date :due_date if self.attribute_names.include?("due_date")
  end

  class_methods do
    def ransack_date(attribute)
      ransacker attribute do
        Arel.sql("date(#{table_name}.#{attribute})")
      end
    end
  end

end