# == Schema Information
#
# Table name: agreements
#
#  id                :integer          not null, primary key
#  agreement_type_id :integer          not null
#  file_file_name    :string(255)      not null
#  file_content_type :string(255)      not null
#  file_file_size    :integer          not null
#  file_updated_at   :datetime         not null
#  version           :string(255)      not null
#  active            :boolean          default(FALSE), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Agreement < ActiveRecord::Base
  belongs_to :agreement_type
  has_many :login_agreement_mappings
  has_many :users, through: :login_agreement_mappings

  validates :agreement_type, presence: true
  validates :file, presence: true
  validates :version, presence: true
  validates :active, presence: true

  scope :without_id, -> (id) { where.not id: id }
  scope :with_type_id, ->(type_id) { where agreement_type_id: type_id }
  scope :active, -> { where active: true }

end
