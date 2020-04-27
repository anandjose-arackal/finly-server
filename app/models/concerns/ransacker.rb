module Ransacker
  extend ActiveSupport::Concern

  # included do
  #   columns_hash.each_pair do |attribute_name, properties|
  #     next unless properties.type == :datetime
  #
  #     ransack_date attribute_name
  #   end
  # end

  class_methods do
    def inherited(sub_class)
      super(sub_class)

      # This block ensure that models where table does not exist does not crash
      begin
        sub_class.columns_hash.each_pair do |attribute_name, properties|
          next unless properties.type == :datetime

          sub_class.ransack_date attribute_name
        end
      rescue
        # Do nothing
      end
    end

    def ransack_date(attribute)
      ransacker attribute do
        Arel.sql("date(#{table_name}.#{attribute})")
      end
    end
  end

end