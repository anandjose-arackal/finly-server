class Admin::Implementations::Master::PolicyUserRole::Import < Admin::Implementations::Processor::Import

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'policy_user_role.import'
  headers({
           "Vendor Payments" => {:policy_name => 'Policy Name',
                    :user_id => 'User Email / Mobile / Employee Id',
                    :purchase_request_initiator => 'Purchase Request Initiator',
                    :purchase_request_reviewer => 'Purchase Request Reviewer' ,
                    :purchase_request_auditor => 'Purchase Request Auditor',
                    :purchase_order_initiator => 'Purchase Order Intiator',
                    :purchase_order_reviewer => 'Purchase Order Reviwer',
                    :purchase_order_auditor => 'Purchase Order Auditor',
                    :goods_receiver => 'Goods Receiver',
                    :po_invoice_initiator => "PO Invoice Initiator",
                    :po_invoice_reviewer => "PO Invoice Reviewer",
                    :po_invoice_auditor => "PO Invoice Auditor",
                    :non_po_invoice_initiator => "Non PO Invoice Initiator",
                    :non_po_invoice_reviewer => "Non PO Invoice Reviewer",
                    :non_po_invoice_auditor => "Non PO INvoice Auditor",
                    :bank_payment_request_initiator => 'Bank Payment Request Initiator',
                    :bank_payment_request_reviewer => 'Bank Payment Request Reviewer',
                    :bank_payment_request_creditor => 'Bank Payment Request Creditor',
                    :bank_payment_request_auditor => 'Bank Payment Request Auditor',
                    :item_master_manager => 'Item Master Manager',
                    :inventory_manager => 'Inventory Manager',
                    :vendor_creator => 'Vendor Creator',
                    :vendor_reviewer => 'Vendor Reviewer',
                    :vendor_auditor => 'Vendor Auditor',
                    :payment_agreement_initiator => "Payment Agreement Initiator",
                    :payment_agreement_reviewer => "Payment Agreement Reviewer" ,
                    :payment_agreement_auditor => "Payement Agreement Auditor",
                    :budget_manager => 'Budget Manager'},

           "Expense Management" => {
               :policy_name => 'Policy Name',
               :user_id => 'User Email / Mobile',
               :intiator => "Intiator",
               :manager => "Manager",
               :finance_manager => "Finance Manager"
           }
  })

  attr_accessor :policy_user_params, :application, :policy, :user_profiles
  def process
    self.user_profiles = UserProfile.joins(:user).where('users.company_id = ?',company.id)
    path = Rails.env.production? ? self.implementation_request.request_file&.url : self.implementation_request.request_file&.path
    self.input = Roo::Spreadsheet.open(path)
    output = {}
    input.each_with_pagename do |name, sheet|
      output[name] = []
      self.application = get_application(name)
      (2..sheet.last_row).each do |i|
        row = sheet.row(i)
        begin
          result = process_row(row)
          unless result.is_a?(Admin::Implementations::Processor::Import::Result)
            item_complete false
            raise "invalid result"
          end
        rescue Exception => e
          result false, "#{e.message}"
        end

        unless result.success?
          item_complete false
          row << result.message
          failed = true
        end
        if result.success?
          row << result.message
          item_complete true
        end
        output[name] << row
      end
      export headers, output
    end

  end

  def export(headers, contents)
    file = Tempfile.new(['pur_import_result', '.xlsx'])
    workbook  = ::WriteXLSX.new(file)
    contents.each  do |name, sheet|
      worksheet = workbook.add_worksheet(name)
      headers[name]&.values.each_with_index do |item, index|
        worksheet.write( 0, index, item )
      end
      sheet.each_with_index do |items, row|
        items.each_with_index do |item, column|
          worksheet.write(1 + row, column, item)
        end
      end
    end
    workbook.close
    file.rewind
    self.implementation_request.result_file = file
    self.implementation_request.save
    progress_update(:completed)
  end

  def process_row(data)
    create_record(data)
  end

  def destroy_records(data)
    result success: false, message: "Destroy action cant perform"
  end

  def update_record(data)
    result success: false, message: "Update action cant perform"
  end

  def create_record(data)
    self.policy_user_params = set_params(data)
    if policy_user_params[:policy_id].present?
      self.policy = get_policy(policy_user_params[:policy_id], application)

    else
      self.policy = company.policies.default.first
    end
    unless policy.present?
      return result false,  "Policy Not Found"
    end

    entity_user_id = clean_up_data policy_user_params[:user_id]
    entity_user = get_user_entity(entity_user_id)
    unless entity_user.present?
      return result false,  "User Not Found"
    end

    if self.application == 'vp'
      policy_user_params[:roles].each do |k,v|
        if v == 'Y'
          role_id = UserRole.id_for(k)
          existing_mapping = policy.policy_user_roles.where(user_role_id: role_id, user_id: entity_user.id).first
          unless existing_mapping.present?
            role_mapping = policy.policy_user_roles.new(user_role_id: role_id, user_id: entity_user.id)
            role_mapping.save
          end
        elsif v == 'N'
          role_id = UserRole.id_for(k)
          existing_mapping = policy.policy_user_roles.where(user_role_id: role_id, user_id: entity_user.id).first
          if existing_mapping.present?
            existing_mapping.destroy
          end
        end
      end
    elsif self.application == 'em'
      policy_user_params[:roles].each do |k,v|
        role_id = UserRole.id_for(k)
        if v == 'Y'
          case k
          when :initiator
            existing_mapping = policy.user_mapping.where(user_id: entity_user.id).first
            unless  existing_mapping
              policy.user_mapping.create(user_id: entity_user.id)
            end
          when :manager
            existing_mapping = entity_user.role_mapping.where(purpose_id: 1, user_role_id: role_id).first
            unless  existing_mapping
              entity_user.role_mapping.create(purpose_id: 1, user_role_id: role_id)
            end
          when :finance_manager
            existing_mapping = policy.policy_user_roles.where(user_role_id: role_id, user_id: entity_user.id).first
            unless  existing_mapping
              role_mapping = policy.policy_user_roles.new(user_role_id: role_id, user_id: entity_user.id)
              role_mapping.save
            end
          end
        elsif v == 'N'
          case k
          when :initiator
            existing_mapping = policy.user_mapping.where(user_id: entity_user.id).first
            if  existing_mapping
              existing_mapping.destroy
            end
          when :manager
            existing_mapping = entity_user.role_mapping.where(purpose_id: 1, user_role_id: role_id).first
            if  existing_mapping
              existing_mapping.destroy
            end
          when :finance_manager
            existing_mapping = policy.policy_user_roles.where(user_role_id: role_id, user_id: entity_user.id).first
            if  existing_mapping
              existing_mapping.destroy
            end
          end
        end

      end
    end
    result true, 'Role Assigned'
  end


  private

  def set_params(row)
    params ={}
    policy_id = row[import_fields[:policy_id]]
    user_id = row[import_fields[:user_id]]
    if self.application == 'em'
      params = {
          policy_id: policy_id,
          user_id:  user_id,
          roles:{
              initiator: row[import_fields[:initiator]].to_s.upcase,
              manager: row[import_fields[:manager]].to_s.upcase,
              finance_manager: row[import_fields[:finance_manager]].to_s.upcase,
          }
      }
    else
      params = {
          policy_id: policy_id,
          user_id: user_id,
          roles: {
              purchase_request_initiator: row[import_fields[:purchase_request_initiator]].to_s.upcase,
              purchase_request_reviewer: row[import_fields[:purchase_request_reviewer]].to_s.upcase,
              purchase_request_auditor: row[import_fields[:purchase_request_auditor]].to_s.upcase,
              purchase_order_initiator: row[import_fields[:purchase_order_initiator]].to_s.upcase,
              purchase_order_reviewer: row[import_fields[:purchase_order_reviewer]].to_s.upcase,
              purchase_order_auditor: row[import_fields[:purchase_order_auditor]].to_s.upcase,
              goods_receiver: row[import_fields[:goods_receiver]].to_s.upcase,
              po_invoice_initiator: row[import_fields[:po_invoice_initiator]].to_s.upcase,
              po_invoice_reviewer: row[import_fields[:po_invoice_reviewer]].to_s.upcase,
              po_invoice_auditor: row[import_fields[:po_invoice_auditor]].to_s.upcase,
              non_po_invoice_initiator: row[import_fields[:non_po_invoice_initiator]].to_s.upcase,
              non_po_invoice_reviewer: row[import_fields[:non_po_invoice_reviewer]].to_s.upcase,
              non_po_invoice_auditor: row[import_fields[:non_po_invoice_auditor]].to_s.upcase,
              bank_payment_request_initiator: row[import_fields[:bank_payment_request_initiator]].to_s.upcase,
              bank_payment_request_reviewer: row[import_fields[:bank_payment_request_reviewer]].to_s.upcase,
              bank_payment_request_creditor: row[import_fields[:bank_payment_request_creditor]].to_s.upcase,
              bank_payment_request_auditor: row[import_fields[:bank_payment_request_auditor]].to_s.upcase,
              item_master_manager: row[import_fields[:item_master_manager]].to_s.upcase,
              inventory_manager: row[import_fields[:inventory_manager]].to_s.upcase,
              vendor_creator: row[import_fields[:vendor_creator]].to_s.upcase,
              vendor_reviewer: row[import_fields[:vendor_reviewer]].to_s.upcase,
              vendor_auditor: row[import_fields[:vendor_auditor]].to_s.upcase,
              payment_agreement_initiator: row[import_fields[:payment_agreement_initiator]].to_s.upcase,
              payment_agreement_reviewer: row[import_fields[:payment_agreement_reviewer]].to_s.upcase,
              payment_agreement_auditor: row[import_fields[:payment_agreement_auditor]].to_s.upcase,
              budget_manager: row[import_fields[:budget_manager]].to_s.upcase
          }
      }
      params
    end

  end

  def import_fields
    if application == 'em'
      {
          :policy_id => 0,
          :user_id => 1,
          :initiator => 2,
          :manager => 3,
          :finance_manager =>4
      }
    else
      {
          :policy_id => 0,
          :user_id => 1,
          :purchase_request_initiator => 2,
          :purchase_request_reviewer => 3,
          :purchase_request_auditor => 4,
          :purchase_order_initiator => 5,
          :purchase_order_reviewer => 6,
          :purchase_order_auditor => 7,
          :goods_receiver => 8,
          :po_invoice_initiator => 9,
          :po_invoice_reviewer => 10,
          :po_invoice_auditor => 11,
          :non_po_invoice_initiator => 12,
          :non_po_invoice_reviewer => 13,
          :non_po_invoice_auditor => 14,
          :bank_payment_request_initiator => 15,
          :bank_payment_request_reviewer => 16,
          :bank_payment_request_creditor => 17,
          :bank_payment_request_auditor => 18,
          :item_master_manager => 19,
          :inventory_manager => 20,
          :vendor_creator => 21,
          :vendor_reviewer => 22,
          :vendor_auditor => 23,
          :payment_agreement_initiator => 24,
          :payment_agreement_reviewer => 25,
          :payment_agreement_auditor=> 26,
          :budget_manager =>27
    }
    end
  end

  def get_policy(policy_name,application)
    policy = self.company.policies.find_by(name: policy_name, application: application)
  end

  def get_application(name)
    'Expense Management' == name ? 'em' : 'vp'
  end

  def clean_up_data(text)
    if text.is_a?(Float) || text.is_a?(Integer)
      text&.to_i&.to_s
    else
      text&.strip
    end
  end

  def get_user_entity(identifier)
    user = nil
    if Constants::VALID_EMAIL_FORMAT.match?(identifier)
      user = company.users.find_by_email identifier
    elsif Constants::VALID_MOBILE_NUMBER.match?(identifier)
      user = company.users.find_by_mobile_number identifier
    else
      user = self.user_profiles.where('user_profiles.employee_id = ?', identifier&.to_s)&.last&.user
    end
    user
  end


end
