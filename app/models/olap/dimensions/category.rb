# == Schema Information
#
# Table name: olap_dimensions_categories
#
#  id           :bigint           not null, primary key
#  finly_ref_id :bigint           not null
#  name         :string(255)
#  gl_code      :string(255)
#  active       :boolean
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Olap::Dimensions::Category < OlapRecord
end
