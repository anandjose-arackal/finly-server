# == Schema Information
#
# Table name: individual_kycs
#
#  id                         :integer          not null, primary key
#  id_proof_file_name         :string(255)
#  id_proof_content_type      :string(255)
#  id_proof_file_size         :integer
#  id_proof_updated_at        :datetime
#  kyc_status_id              :integer
#  user_id                    :integer          not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  address_proof_file_name    :string(255)
#  address_proof_content_type :string(255)
#  address_proof_file_size    :integer
#  address_proof_updated_at   :datetime
#

class IndividualKyc < ActiveRecord::Base
  include Attachable

  belongs_to :user
  belongs_to :kyc_status
  has_many :system_messages, as: :messagable, dependent: :destroy

  CONTENT_TYPES = {content_type: %w(image/jpg image/jpeg image/png image/gif application/pdf application/rtf)}

  has_attached_file :id_proof, styles: lambda { |a| a.instance.check_file_type(a) }, default_url: '/assets/:style/missing.png'
  validates_attachment :id_proof, content_type: CONTENT_TYPES

  has_attached_file :address_proof, styles: lambda { |a| a.instance.check_file_type(a) }, default_url: '/assets/:style/missing.png'
  validates_attachment :address_proof, content_type: CONTENT_TYPES

  def editable?
    [KycStatus.id_for(:incomplete), KycStatus.id_for(:submitted), KycStatus.id_for(:error)].include?(kyc_status_id)
  end
end
