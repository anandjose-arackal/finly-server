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
#  upgraded_on                :datetime
#  aadhar_front_file_name     :string(255)
#  aadhar_front_content_type  :string(255)
#  aadhar_front_file_size     :integer
#  aadhar_front_updated_at    :datetime
#  aadhar_back_file_name      :string(255)
#  aadhar_back_content_type   :string(255)
#  aadhar_back_file_size      :integer
#  aadhar_back_updated_at     :datetime
#  photo_file_name            :string(255)
#  photo_content_type         :string(255)
#  photo_file_size            :integer
#  photo_updated_at           :datetime
#  signature_file_name        :string(255)
#  signature_content_type     :string(255)
#  signature_file_size        :integer
#  signature_updated_at       :datetime
#  combined_kyc_file_name     :string(255)
#  combined_kyc_content_type  :string(255)
#  combined_kyc_file_size     :integer
#  combined_kyc_updated_at    :datetime
#  kyc_1_front_file_name      :string(255)
#  kyc_1_front_content_type   :string(255)
#  kyc_1_front_file_size      :integer
#  kyc_1_front_updated_at     :datetime
#  kyc_1_back_file_name       :string(255)
#  kyc_1_back_content_type    :string(255)
#  kyc_1_back_file_size       :integer
#  kyc_1_back_updated_at      :datetime
#  kyc_2_front_file_name      :string(255)
#  kyc_2_front_content_type   :string(255)
#  kyc_2_front_file_size      :integer
#  kyc_2_front_updated_at     :datetime
#  kyc_2_back_file_name       :string(255)
#  kyc_2_back_content_type    :string(255)
#  kyc_2_back_file_size       :integer
#  kyc_2_back_updated_at      :datetime
#  kyc_1_number               :string(255)
#  kyc_2_number               :string(255)
#

require 'fileutils'
class IndividualKyc < ApplicationRecord
  include Attachable, Magick

  belongs_to :user, optional: true
  belongs_to :kyc_status, optional: true
  belongs_to :type, optional: true, class_name: 'IndividualKycType'
  belongs_to :admin_review_workflow, optional: true
  belongs_to :company, optional: true
  belongs_to :upgraded_by_resource, optional: true, class_name: 'AdminUser'
  has_many :tracks, class_name: 'IndividualKycTrack'
  has_many :system_messages, as: :messagable, dependent: :destroy

  delegate :aadhar_card?, :driving_license?, :voter_id?, :ngera_job_card?, :passport?, to: :type, allow_nil: true

  scope :with_admin_review_workflow, -> (workflow_id) { where admin_review_workflow_id: workflow_id }
  scope :with_review_position, ->(review_pos) { where review_position: review_pos }
  scope :filter_company_id, ->(company_id) { where company_id: company_id }
  scope :with_user_id, -> (id) { where user_id: id }
  scope :with_id, -> (id) { where id: id }
  scope :without_id, -> (id) { where.not id: id }
  scope :include_tracks, -> { includes :tracks }

  default_scope { order submitted_on: :asc }

  CONTENT_TYPES = {content_type: %w(image/jpg image/jpeg image/png)}
  IMAGE_STYLE = { original: ['100%', :jpg], thumb: ['500x500>', :jpg], large: ['2160x2160>', :jpg], normal: ['1080x1080>', :jpg] }

  ## DEPRICATED START ##
  has_attached_file :id_proof, styles: lambda { |a| a.instance.check_file_type(a) }, default_url: '/assets/:style/missing.png'
  validates_attachment :id_proof, content_type: CONTENT_TYPES

  has_attached_file :address_proof, styles: lambda { |a| a.instance.check_file_type(a) }, default_url: '/assets/:style/missing.png'
  validates_attachment :address_proof, content_type: CONTENT_TYPES

  has_attached_file :kyc_file_1, styles: IMAGE_STYLE, default_url: '/assets/:style/missing.png'
  validates_attachment :kyc_file_1, content_type: CONTENT_TYPES

  has_attached_file :kyc_file_2, styles: IMAGE_STYLE, default_url: '/assets/:style/missing.png'
  validates_attachment :kyc_file_2, content_type: CONTENT_TYPES
  ## DEPRICATED END ##

  has_attached_file :aadhar_front, styles: IMAGE_STYLE, default_url: '/assets/:style/missing.png'
  validates_attachment :aadhar_front, content_type: CONTENT_TYPES

  has_attached_file :aadhar_back, styles: IMAGE_STYLE, default_url: '/assets/:style/missing.png'
  validates_attachment :aadhar_back, content_type: CONTENT_TYPES

  has_attached_file :kyc_1_front, styles: IMAGE_STYLE, default_url: '/assets/:style/missing.png'
  validates_attachment :kyc_1_front, content_type: CONTENT_TYPES

  has_attached_file :kyc_1_back, styles: IMAGE_STYLE, default_url: '/assets/:style/missing.png'
  validates_attachment :kyc_1_back, content_type: CONTENT_TYPES

  has_attached_file :kyc_2_front, styles: IMAGE_STYLE, default_url: '/assets/:style/missing.png'
  validates_attachment :kyc_2_front, content_type: CONTENT_TYPES

  has_attached_file :kyc_2_back, styles: IMAGE_STYLE, default_url: '/assets/:style/missing.png'
  validates_attachment :kyc_2_back, content_type: CONTENT_TYPES

  has_attached_file :photo, styles: IMAGE_STYLE, default_url: '/assets/:style/missing.png'
  validates_attachment :photo, content_type: CONTENT_TYPES

  has_attached_file :signature, styles: IMAGE_STYLE, default_url: '/assets/:style/missing.png'
  validates_attachment :signature, content_type: CONTENT_TYPES

  has_attached_file :combined_kyc, styles: IMAGE_STYLE, default_url: '/assets/:style/missing.png'
  validates_attachment :combined_kyc, content_type: CONTENT_TYPES

  def processing?
    KycStatus.ids_for([:processing, :submitted]).include?(self.kyc_status_id)
  end

  def incomplete?
    KycStatus.id_for(:incomplete) == self.kyc_status_id
  end

  def retracted?
    KycStatus.id_for(:retracted) == self.kyc_status_id
  end

  def rejected?
    KycStatus.id_for(:rejected) == self.kyc_status_id
  end

  def completed?
    KycStatus.id_for(:completed) == self.kyc_status_id
  end

  def editable?
    [KycStatus.id_for(:incomplete), KycStatus.id_for(:rejected), KycStatus.id_for(:retracted)].include?(kyc_status_id)
  end

  def retractable?
    [KycStatus.id_for(:submitted)].include?(kyc_status_id)
  end

  def generate_single_kyc
    return false unless can_submit?
    view = ActionView::Base.new(ActionController::Base.view_paths)
    view.extend ApplicationHelper
    html_string = view.render(file: 'kyc/user/kyc_template.html.erb', locals: {kyc: self})

    FileUtils::mkdir_p "#{Rails.root}/tmp/images"
    image_tmp_path = "#{Rails.root}/tmp/images/#{id}_combined_kyc.jpg"
    converter = ReceiptProcessor::HTMLConverter.new
    self.combined_kyc = converter.convert(html_string, image_tmp_path)&.first
    self.save
  end

  def can_submit?
    return false if require_photo? and not self.photo.present?
    return false unless self.kyc_1_front.present? and self.kyc_1_back.present?
    true
  end

  def require_photo?
    [nil, 'HDFC'].include?(self.user.company.configuration.bank_type&.upcase)
  end

end
