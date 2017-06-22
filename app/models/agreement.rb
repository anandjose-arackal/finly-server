class Agreement < ActiveRecord::Base
  belongs_to :agreement_type
  has_many :login_agreement_mappings
  has_many :users, through: :login_agreement_mappings

  validates :agreement_type, presence: true
  validates :file, presence: true
  validates :version, presence: true
  validates :active, presence: true

end
