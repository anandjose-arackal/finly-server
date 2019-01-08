# class User::DelegateMappings::Create < User::Base
#   attr_accessor :user_delegation_mappings

#   def init
#     self.user_delegation_mappings = params[:user_delegation_mappings]
#   end

#   def validate
#     unless user_delegation_mappings.present?
#         add_message :error, "Unable to delegate this user"
#     end
#   end

#   def process
#     user_delegation_mappings.each do |delegate_for_user_id|
#       user_delegation_mappings = user.user_delegation_mappings.create user_id: user.id,
#                                                                       delegate_for_user_id: delegate_for_user_id
#     end
#     unless user_delegation_mappings.blank?
#       add_message :error, "Unable to delegate this user"
#     end
#   end 

#   def post_process
#     add_message :success, "New user delegates added"
#   end
# end