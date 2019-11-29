# == Schema Information
#
# Table name: olap_dimensions_categories
#
#  id                   :bigint           not null, primary key
#  finly_ref_id         :bigint           not null
#  finly_ref_created_at :datetime
#  finly_ref_updated_at :datetime
#  name                 :string(255)
#  gl_code              :string(255)
#  active               :boolean
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class Olap::Dimensions::Category < OlapRecord
  include Analytics::Mapper

  transaction_model ::Category
  events 'category.update', 'category.create'

  map :name
  map :gl_code
  map :active

end
