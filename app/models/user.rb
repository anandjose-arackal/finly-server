class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable, :lockable

  belongs_to :company
  has_one :profile, class_name: 'UserProfile', dependent: :destroy
  belongs_to :user_type

  has_many :team_mapping, class_name: "UserManagerMapping"

  after_create do
    self.build_profile.save
    self.team_mapping.build(default: true)
  end

end
