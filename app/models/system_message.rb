# == Schema Information
#
# Table name: system_messages
#
#  id                     :integer          not null, primary key
#  content                :text(65535)      not null
#  system_message_type_id :integer          not null
#  messagable_id          :integer
#  messagable_type        :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class SystemMessage < ActiveRecord::Base
  include SoftDeletable

  belongs_to :system_message_type
  belongs_to :messagable, polymorphic: true
end
