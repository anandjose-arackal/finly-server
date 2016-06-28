class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable, :lockable

  belongs_to :company
  has_one :profile, class_name: 'UserProfile', dependent: :destroy
  belongs_to :user_type

  validates :company_id, presence: true
  validates :user_type_id, presence: true
  validates :email, presence: true, format: Constants::VALID_EMAIL_FORMAT, uniqueness: {case_sensitive: false}
  validates :name, presence: true

  has_many :team_mapping, class_name: "UserManagerMapping"

  after_create do
    self.build_profile.save
    self.team_mapping.build(default: true).save
  end

  def admin?

  end

  def finance_manager?

  end

  def manager?

  end

  def employee?

  end

end
