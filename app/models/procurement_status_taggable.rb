# == Schema Information
#
# Table name: procurement_status_taggables
#
#  id             :integer          not null, primary key
#  procurement_id :integer
#  status_tag_id  :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class ProcurementStatusTaggable < ActiveRecord::Base
  belongs_to :procurement
  belongs_to :status_tag

  scope :with_procurement_ids, -> (ids) {where procurement_id: ids}
  scope :with_status_tag_ids, -> (ids) {where status_tag_id: ids}
end
