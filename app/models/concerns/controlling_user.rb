module ControllingUser
  
  include Ransacker
  extend ActiveSupport::Concern

  included do
    ransacker :controlling_user,
    args: [:parent, :ransacker_args] do |parent, args|
      query = "
        true ) AND #{parent.table.name}.id IN 
          ( SELECT #{parent.table.name}.id from #{parent.table.name}
          INNER JOIN document_level_reviewer_mappings ON
          document_level_reviewer_mappings.level_id = #{parent.table.name}.controlling_level_id AND
          document_level_reviewer_mappings.document_reviewer_mappable_id = #{parent.table.name}.id
          WHERE document_level_reviewer_mappings.reviewer_id  "

      Arel.sql(query)
    end
  end

end