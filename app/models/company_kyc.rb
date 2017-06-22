# == Schema Information
#
# Table name: company_kycs
#
#  id                            :integer          not null, primary key
#  pan_card_file_name            :string(255)
#  pan_card_content_type         :string(255)
#  pan_card_file_size            :integer
#  pan_card_updated_at           :datetime
#  coi_file_name                 :string(255)
#  coi_content_type              :string(255)
#  coi_file_size                 :integer
#  coi_updated_at                :datetime
#  agreement_file_name           :string(255)
#  agreement_content_type        :string(255)
#  agreement_file_size           :integer
#  agreement_updated_at          :datetime
#  board_resolution_file_name    :string(255)
#  board_resolution_content_type :string(255)
#  board_resolution_file_size    :integer
#  board_resolution_updated_at   :datetime
#  kyc_status_id                 :integer
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  company_id                    :integer          not null
#

class CompanyKyc < ActiveRecord::Base
  include Attachable

  belongs_to :company
  belongs_to :kyc_status

  CONTENT_TYPES = {content_type: %w(image/jpg image/jpeg image/png image/gif application/pdf application/rtf)}

  has_attached_file :coi, styles: lambda { |a| a.instance.check_file_type(a) }, default_url: '/assets/:style/missing.png'
  validates_attachment :coi, content_type: CONTENT_TYPES

  has_attached_file :pan_card, styles: lambda { |a| a.instance.check_file_type(a) }, default_url: '/assets/:style/missing.png'
  validates_attachment :pan_card, content_type: CONTENT_TYPES

  has_attached_file :agreement, styles: lambda { |a| a.instance.check_file_type(a) }, default_url: '/assets/:style/missing.png'
  validates_attachment :agreement, content_type: CONTENT_TYPES

  has_attached_file :board_resolution, styles: lambda { |a| a.instance.check_file_type(a) }, default_url: '/assets/:style/missing.png'
  validates_attachment :board_resolution, content_type: CONTENT_TYPES

end
