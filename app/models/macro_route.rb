# == Schema Information
#
# Table name: macro_routes
#
#  id         :bigint           not null, primary key
#  macro_id   :integer
#  route      :string(255)      not null
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class MacroRoute < FinlyMacrosRecord

  belongs_to :company
  belongs_to :macro

  def as_json(options = {})
    {
        id: id,
        route: route
    }
  end

end
