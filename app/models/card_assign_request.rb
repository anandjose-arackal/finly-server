# == Schema Information
#
# Table name: card_assign_requests
#
#  id                        :integer          not null, primary key
#  card_id                   :integer
#  card_owner_id             :integer          not null
#  initiating_resource_id    :integer          not null
#  initiating_resource_type  :string(255)      not null
#  status_id                 :integer          not null
#  assigned_by_resource_id   :integer
#  assigned_by_resource_type :string(255)
#  assigned_on               :datetime
#  card_program_id           :integer          not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  admin_review_workflow_id  :integer
#  review_position           :integer          default(0)
#  admin_note                :text(65535)
#  company_id                :integer          not null
#

class CardAssignRequest < ActiveRecord::Base
  belongs_to :card
  belongs_to :card_program
  belongs_to :status, class_name: 'CardAssignRequestStatus'
  belongs_to :card_owner, class_name: 'User'
  belongs_to :initiating_resource, polymorphic: true
  belongs_to :assigned_by_resource, polymorphic: true
  belongs_to :admin_review_workflow
  belongs_to :company

  has_many :tracks, class_name: 'CardAssignRequestTrack', dependent: :destroy

  default_scope { where.not status_id: CardAssignRequestStatus.id_for(:cancelled) }

  validates :card_id, presence: true
  validates :card_program_id, presence: true
  validates :status_id, presence: true
  validates :card_owner_id, presence: true
  validates :initiating_resource, presence: true
  validates :admin_review_workflow, presence: true

  scope :with_admin_review_workflow, -> (workflow_id) { where admin_review_workflow_id: workflow_id }
  scope :with_review_position, ->(review_pos) { where review_position: review_pos }
  scope :filter_company_id, ->(company_id) { where company_id: company_id }
  scope :with_card_owner_id, -> (id) { where card_owner_id: id }
  scope :with_id, -> (id) { where id: id }
  scope :without_id, -> (id) { where.not id: id }
  scope :include_tracks, -> { includes :tracks }
  scope :approved, -> { where status_id: CardAssignRequestStatus.id_for(:approved) }
  scope :processing, -> { where status_id: CardAssignRequestStatus.id_for(:processing) }
  scope :assignable, -> { where status_id: CardAssignRequestStatus.ids_for([:processing, :approved, :rejected]) }

  def processing?
    self.status_id == CardAssignRequestStatus.id_for(:processing)
  end

  def cancellable?
    [CardAssignRequestStatus.id_for(:rejected)].include?(self.status_id)
  end

end
