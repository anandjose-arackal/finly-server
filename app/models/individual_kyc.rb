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
#  review_position            :integer
#  admin_review_workflow_id   :integer          not null
#  upgraded_by_resource_id    :integer
#  proof_file_1_file_name     :string(255)
#  proof_file_1_content_type  :string(255)
#  proof_file_1_file_size     :integer
#  proof_file_1_updated_at    :datetime
#  proof_file_1               :string(255)
#  proof_file_2_file_name     :string(255)
#  proof_file_2_content_type  :string(255)
#  proof_file_2_file_size     :integer
#  proof_file_2_updated_at    :datetime
#  proof_file_2               :string(255)
#  type_id                    :integer
#  kyc_file_1_file_name       :string(255)
#  kyc_file_1_content_type    :string(255)
#  kyc_file_1_file_size       :integer
#  kyc_file_1_updated_at      :datetime
#  kyc_file_2_file_name       :string(255)
#  kyc_file_2_content_type    :string(255)
#  kyc_file_2_file_size       :integer
#  kyc_file_2_updated_at      :datetime
#  kyc_number                 :string(255)
#  company_id                 :integer          not null
#  admin_note                 :text(65535)
#  submitted_on               :datetime
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
