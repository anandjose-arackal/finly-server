module Ransacker
  extend ActiveSupport::Concern

  included do
    ransacker :created_at do
      Arel.sql("date(invoices.created_at)")
    end

    ransacker :updated_at do
      Arel.sql("date(invoices.updated_at)")
    end

    ransacker :deleted_at do
      Arel.sql("date(invoices.deleted_at)")
    end
  end

end