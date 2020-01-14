# == Schema Information
#
# Table name: form_dependency_types
#
#  id         :bigint           not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class FormDependencyType < ApplicationRecord
  include Seedable

  def self.values
    [:user, :field]
  end

end
