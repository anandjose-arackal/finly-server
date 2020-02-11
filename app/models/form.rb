# == Schema Information
#
# Table name: forms
#
#  id         :bigint           not null
#  uuid       :string(36)       not null, primary key
#  klass_name :string(255)      not null
#  model      :string(255)      not null
#  company_id :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

class Form < ApplicationRecord
  include UUIDHelper, SoftDeletable

  has_many :sections, class_name: 'FormSection', dependent: :destroy

  def as_json(options = {})
    {
        id: id,
        sections: sections
    }
  end
end
