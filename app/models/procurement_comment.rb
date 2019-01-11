# == Schema Information
#
# Table name: procurement_comments
#
#  id                      :integer          not null, primary key
#  body                    :text(65535)
#  user_id                 :integer
#  parent_commentable_id   :integer
#  parent_commentable_type :string(255)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  is_deleted              :boolean          default(FALSE), not null
#

class ProcurementComment < ApplicationRecord
  include SoftDeletable
  belongs_to :user, optional: true

  belongs_to :parent_commentable, optional: true, polymorphic: true
end
