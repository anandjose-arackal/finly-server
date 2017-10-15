# == Schema Information
#
# Table name: quickbooks_references
#
#  id                :integer          not null, primary key
#  name              :string(255)
#  company_id        :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  reference_type_id :integer
#

class QuickbooksReference < ActiveRecord::Base

  belongs_to :company
  has_many :field_configurations, as: :external_reference
  belongs_to :reference_type, class_name: "QuickbooksReferenceType"

  def quickbooks_department?
    self.reference_type_id == QuickbooksReferenceType.id_for(:department)
  end
end
