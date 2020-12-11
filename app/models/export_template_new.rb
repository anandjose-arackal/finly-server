# == Schema Information
#
# Table name: export_template_news
#
#  id                    :bigint           not null, primary key
#  name                  :string(255)      not null
#  description           :text(65535)
#  export_format         :string(255)      not null
#  resource              :string(255)      not null
#  template              :text(4294967295)
#  query                 :text(4294967295)
#  active                :boolean          default(TRUE)
#  personal              :boolean
#  company_id            :integer
#  created_by_id         :integer
#  deleted_at            :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

class ExportTemplateNew < ApplicationRecord
  belongs_to :company
  belongs_to :created_by, class_name: 'User', optional: true

  has_many :role_mappings, class_name: 'ExportTemplateUserRoleMapping', foreign_key: 'template_id', dependent: :destroy
  has_many :user_roles, through: :role_mappings, dependent: :destroy

  serialize :query, JSON

  scope :filter_resource, -> (resource) { where resource: resource }
  scope :filter_default, -> { where default: true }
  scope :filter_route, -> (route) { where resource: ExportResource.where(route: route).pluck(:value) }

  def system_template?
    return self.master.present?
  end

  def self.seed_data
    Company.find_each do |company|
      ExportManager::TemplateMaster.subscribers.each do |_, list|
        list.each do |master|
          master.create_or_update_template!(company)
        end
      end
    end
  end
end
