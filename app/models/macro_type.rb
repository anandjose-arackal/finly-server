# == Schema Information
#
# Table name: macro_types
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class MacroType < FinlyMacrosRecord
  include Seedable

  # set_values :integration#, :automation, :form_validation_rule, :button

  def self.values
    [:integration]
  end

end
