 class Policy::ApprovalWorkflows::Configs::Base < BaseOperation
   attr_accessor :file, :result_hash, :header, :policy, :sheet, :company

   def pre_validate
     if user.blank? || params.blank?
       add_message :error, "Invalid parameters. please try again"
     end
   end

   def user_model
     [User, AdminUser]
   end

   def init
     self.company = params[:company_id]
     self.file = params[:file]
     self.result_hash = {}
   end

   def validate
     if file.nil? || sheet.nil?
       add_message :error, "No file uploaded, please attach a file and try again"
     end

     if company.nil?
       add_message :error, "Company not present"
     end
   end

 end