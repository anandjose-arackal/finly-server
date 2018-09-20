module FindByOrderedIds
  extend ActiveSupport::Concern
  module ClassMethods
    def find_ordered(ids)
      sanitized_id_string = ids.map {|id| connection.quote(id)}.join(",")
      where(id: ids).reorder("FIELD(#{self.table_name}.id, #{sanitized_id_string})")
    end
  end
end