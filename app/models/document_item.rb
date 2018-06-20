class DocumentItem < ActiveRecord::Base
  belongs_to :inventory_line_item
end
