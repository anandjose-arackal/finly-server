class Admin::Base < BaseOperation

  def user_model
    AdminUser
  end

  def authorize_user(user_types)
    return if user_types.blank?
    user_types = [user_types] unless user_types.is_a?(Array)
    if user.present?
      user_types.each do |user_type|
        if (user_type == :verifier and user.verifier?) or (user_type == :admin and user.admin?) or
            (user_type == :transcriber and user.transcriber?) or(user_type == :itzcash_verifier and user.itzcash_verifier?) or
            (user_type == :itzcash_operations and user.itzcash_operations?) or (user_type == :call_center and user.call_center?) or (user_type == :superadmin and user.superadmin?)
          return
        end
      end
    end
  end

end