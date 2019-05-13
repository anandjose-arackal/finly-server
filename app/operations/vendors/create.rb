class Vendors::Create < Vendors::Base
  attr_accessor :vendor_parameters, :vendor, :account_owner_type, :similar_vendors,
                :override_vendor_id

  class Vendors::Create::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :vendor

    def init
      self.vendor = params[:vendor]
    end
  end

  def personalizer
    {
        validate: {
            after: Personalizer::Process.new([:vendors, :create], :validate, self)
        }
    }
  end

  def init
    # super()
    self.vendor_parameters = vendor_attributes
    self.similar_vendors = []
    self.override_vendor_id = StringUtils.to_bool(vendor_parameters[:override_vendor_id])
    # setting account owner type as vendor
  end

  def validate
    # Policy Selection
    policies = Policy::VendorPayments::Index.(user, {filter_role_id: [UserRole.id_for(:vendor_creator)]}).policies
    if user.company.vendor_empanelment_workflow_enabled?
      unless user.is_vendor_manager?

        policy_ids = policies.pluck(:id)
        parameters = {
          filter_associated_entity_type: "YesBankVendorProvider",
          filter_policy_ids: policy_ids
        }

        levels = ReviewalLevels::Index.(user, parameters).levels

        if levels.present?
          unless self.vendor_parameters[:policy_id].present?
            add_message :error, "Please select a policy"
          end

          unless policy_ids.include?(vendor_parameters[:policy_id].to_i)
            add_message :error, "Unknown policy"
          end
        end
      end
    end


    if user.company_id == 156
      unless vendor_parameters[:pan].present?
        add_message :error, "Please provide PAN to proceed"
        return
      else
        validate_attachment(vendor_parameters, :pan)
      end

    if vendor_parameters[:pan].present?
      existing_pan = user.company.yes_bank_vendors.find_by pan: vendor_parameters[:pan]
      if existing_pan.present?
        add_message :error, "Another Vendor existed with this PAN"
      end
    end

    if vendor_parameters[:msme_registered].present? && (vendor_parameters[:msme_registered] == 1 || vendor_parameters[:msme_registered] == '1')
      validate_attachment(vendor_parameters, :msme_certificate)
    end

      if vendor_parameters[:gst_registered].present? && (vendor_parameters[:gst_registered] == 1 || vendor_parameters[:gst_registered] == '1')
        validate_attachment(vendor_parameters, :gstin)
        validate_gstin(vendor_parameters)
        # validate_business_name(vendor_parameters)
        # validate_pan(vendor_parameters)
      end
    end

    # checking if a particular bank account already exists, if it does, just mark that respective vendor
    # as authorized and add the bank account to their existing list
    if self.vendor_parameters[:bank_accounts_attributes].present?
      self.vendor_parameters[:bank_accounts_attributes].each_with_index do |account_params, index|
        ba = user.company.bank_accounts.find_by(account_number: account_params[:account_number], ifsc: account_params[:ifsc], account_owner_type: "YesBankVendor")
        if ba.present?
          existing_vendor = ba.account_owner
          if existing_vendor.authorized
            add_message :error, "Bank account number #{ba.account_number} already belongs to vendor - #{existing_vendor.business_name} - #{existing_vendor.vendor_id}"
            break
          else
            self.similar_vendors.push(existing_vendor)
            self.vendor_parameters[:bank_accounts_attributes][index][:id] = ba.id
          end
        end
      end
    end

    # There should be only one unique vendor inside similar vendors
    similar_vendor_ids = self.similar_vendors.map(&:id).uniq.reject {|id| id.blank? }
    if similar_vendor_ids.length > 1
      add_message :error, "There are other vendors present with the provided bank accounts"
      return
    end

    self.vendor = self.similar_vendors.first rescue nil
  end

  def pre_process
    # setting the first account as default if none of them are marked as default
    # todo - temporary fix, will be taken in the front end later
    default = false
    if self.vendor_parameters[:bank_accounts_attributes].present?
      self.vendor_parameters[:bank_accounts_attributes].each do |param|
        if [true].include?(StringUtils.to_bool param[:default_account])
          default = true
        end
      end
      unless default
        if vendor_parameters[:bank_accounts_attributes]&.first.present?
          vendor_parameters[:bank_accounts_attributes]&.first[:default_account] = '1'
        end
      end
    end

    # if the receipt is being uploaded, delete the 'remove_file' key
    if vendor_parameters&.dig(:vendor_attachments_attributes).present?
      vendor_parameters[:vendor_attachments_attributes].first&.delete(:remove_file)
    end

    # Remove tds from vendor params if tds_rates_list_id is blank
    vendor_parameters[:vendor_tds_rates_attributes].each_with_index do |vtra, index|
      unless vtra[:tds_rates_list_id].present?
        vendor_parameters[:vendor_tds_rates_attributes].delete_at(index)
      end
    end

    # Remove Empty gstin locations
    vendor_parameters[:gstin_locations_attributes].each_with_index do |gst, index|
      unless gst.keys.present?
        vendor_parameters[:gstin_locations_attributes].delete_at(index)
      end
    end

    # adding the created by user for this particular vendor
    vendor_parameters[:created_by_id] = user.id

    # here we will set the vendor_id based on the override_vendor_id flag from the frontend
    unless self.override_vendor_id
      self.vendor_parameters.delete(:vendor_id)
    end
    self.vendor_parameters.delete(:override_vendor_id)
  end

  def process
    if self.vendor.present? && self.vendor.is_a?(YesBankVendor)
      # if self.vendor_parameters[:bank_accounts_attributes].present?
      #   self.vendor_parameters[:bank_accounts_attributes].each do |account_params|
      #     bank_account = self.vendor.bank_accounts.build(account_params)
      #     unless bank_account.save
      #       add_message :error, bank_account.errors.full_messages
      #     end
      #   end
      # end
      # also mark the vendor as authorized now
      self.vendor.assign_attributes(vendor_parameters)
      self.vendor.authorized = true
      self.vendor.status_id = VendorStatus.id_for(:auto_approved)

      if user.company.vendor_empanelment_workflow_enabled?
        self.vendor.update(status_id: VendorStatus.id_for(:draft))

        # Create Document Level Reviewer Mapping
        # For setting level specific reviewers from reviewal chain for a document
        params[:reviewal_document] = self.vendor

        document_reviewer_mappings_op = ::ReviewalManager::DocumentReviewalMappings::Set.(user, params)
        unless document_reviewer_mappings_op.success?
          add_message :error, document_reviewer_mappings_op.messages[:error]
        end
        return
      else
        self.vendor.update(status_id: VendorStatus.id_for(:auto_approved))
      end


      if self.vendor.save
        if user.company.vendor_empanelment_workflow_enabled?
          self.vendor.update(status_id: VendorStatus.id_for(:draft))

          # Create Document Level Reviewer Mapping
          # For setting level specific reviewers from reviewal chain for a document
          params[:reviewal_document] = self.vendor

          document_reviewer_mappings_op = ::ReviewalManager::DocumentReviewalMappings::Set.(user, params)
          unless document_reviewer_mappings_op.success?
            add_message :error, document_reviewer_mappings_op.messages[:error]
          end
          return
        else
          self.vendor.update(status_id: VendorStatus.id_for(:auto_approved))
        end  
      else
        add_message :error, vendor.errors.full_messages
      end
    else
      self.vendor = user.company.yes_bank_vendors.build(vendor_parameters)
      self.vendor.authorized = true
      validate_custom_fields(true)
      return if has_errors?
      if self.vendor.save
        if user.company.vendor_empanelment_workflow_enabled?
          self.vendor.update(status_id: VendorStatus.id_for(:draft))

          # Create Document Level Reviewer Mapping
          # For setting level specific reviewers from reviewal chain for a document
          params[:reviewal_document] = self.vendor

          document_reviewer_mappings_op = ::ReviewalManager::DocumentReviewalMappings::Set.(user, params)
          unless document_reviewer_mappings_op.success?
            add_message :error, document_reviewer_mappings_op.messages[:error]
          end
          return
        else
          self.vendor.update(status_id: VendorStatus.id_for(:auto_approved))
        end
      else
        add_message :error, vendor.errors.full_messages
      end
    end
  end

  def post_process
    add_message :success, "Vendor added"
  end

  def success
    params[:vendor] = self.vendor
    BankTransfer::Vendors::Create::SuccessPresenter.new(user, params, messages)
  end
end