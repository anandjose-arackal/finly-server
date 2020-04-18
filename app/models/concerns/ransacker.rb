module Ransacker
  extend ActiveSupport::Concern

  included do
    ransack_date :created_at
    ransack_date :updated_at
    ransack_date :deleted_at
    # ransacker :created_at do
    #   Arel.sql("date(invoices.created_at)")
    # end
    #
    # ransacker :updated_at do
    #   Arel.sql("date(invoices.updated_at)")
    # end
    #
    # ransacker :deleted_at do
    #   Arel.sql("date(invoices.deleted_at)")
    # end
  end

  class_methods do
    def ransack_date(attribute)
      ransacker attribute do
        Arel.sql("date(invoices.#{attribute})")
      end
    end
  end

end