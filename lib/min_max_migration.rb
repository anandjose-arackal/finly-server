class MinMaxMigration
  attr_accessor :result_updated, :result_destroyed, :result_dlrm, :file_url

  def initialize
    self.result_updated = []
    self.result_destroyed = []
    self.result_dlrm = []
    self.file_url = "/home/centos/app/current/log/"   #loction_for_write_output

  end

  def process
    # migrate_lrm
    # migrate_lurm
    # result_one
    migrate_dlrm
    result_two
  end

  def next_greater(array, i)
    array.each do|val|
      if val > i
        return val
      end
    end
    return nil
  end

  def migrate_lrm
    companies = Company.all
    companies.each do |company|
      company.policies.includes(levels:[:level_reviewer_mappings, :level_user_reviewer_mappings]).each do |policy|
        policy.levels.non_deleted.each do |level|
          level.level_reviewer_mappings.non_deleted.group_by(&:reviewer_id).map do |reviewer_id, mapping|
            #collect threshold seted against all other users in same level with ascending order
            others_thresholds = level.level_reviewer_mappings.non_deleted.where.not(reviewer_id: reviewer_id).collect(&:threshold)&.sort
            if others_thresholds.present?
              my_thresholds = mapping.collect(&:threshold) #collect thresolds for a reviewer
              my_min = my_thresholds.min #lower value of the one reviwer thresolds is allways his minimum
              my_highest_threshold = my_thresholds.max #getting highest threshold cuurently assigned in system
              my_max = next_greater(others_thresholds,my_highest_threshold)
              my_max  = nil if my_max == my_highest_threshold
              if my_max == 99999999999999 || my_max == 0.0
                my_max = nil
              end
            else # no other mapping presented in the level; max is infinity
              my_max = nil
              my_thresholds = mapping.collect(&:threshold) #collect thresolds for a reviewer
              my_min = my_thresholds.min #lower value of the one reviwer thresolds is allways his minimum
            end

            #check its deviation workflow
            exception = mapping.collect(&:exception).first
            wo_exception = mapping.collect(&:wo_exception).first

            #destroy current mappings
            dlt_lurms = level.level_reviewer_mappings.where(reviewer_id: reviewer_id)
            dlt_lurms.each do |dlt_lrm|
              result_destroyed << {"policy_id" => policy.id, "level_id" => level.id, "reviewer_id" => dlt_lrm.reviewer_id,  "exception" => dlt_lrm.exception, "wo_exception" => dlt_lrm.wo_exception }
            end
            dlt_lurms.destroy_all

            #create new
            level.level_reviewer_mappings.create(min: my_min, max: my_max, exception: exception, wo_exception: wo_exception, reviewer_id: reviewer_id)
            result_updated << {"policy_id" => policy.id, "level_id" => level.id, "reviewer_id" => reviewer_id, "max" => my_max, "min" => my_min, "exception" => exception, "wo_exception" => wo_exception }
          end
        end
      end
    end
  end

  def migrate_lurm
    companies = Company.all
    companies.each do |company|
      company.policies.includes(levels:[:level_reviewer_mappings, :level_user_reviewer_mappings]).each do |policy|
        policy.levels.non_deleted.each do |level|
          #for lurms
          level.level_user_reviewer_mappings.group_by(&:user_id).map do |user_id, mappings|
            # in LURM except one company all other have single mapping we directly find and update it
            if mappings.count == 1
              mapping = mappings.first
              if mapping.threshold ==  0.0
                my_min = 0
                my_max = nil
              else
                my_min = mapping.threshold
                my_max = nil
              end

              mapping.update_columns(min: my_min, max: my_max)
              result_updated << {"policy_id" => policy.id, "level_id" => level.id, "reviewer_id" => mapping.reviewer_id, "max" => my_max, "min" => my_min, "exception" => mapping.exception, "wo_exception" => mapping.wo_exception, "user_id" => mapping.user_id }
            else
              unique_reviewer_ids = mappings.map {|item| item['reviewer_id']}.uniq
              unique_reviewer_ids.each do |reviewer_id|
                sample = mappings.select {|item| item['reviewer_id'] == reviewer_id }[0]
                min = mappings.select{|item| item['reviewer_id'] == reviewer_id}.min_by {|item| item['threshold']}['threshold']
                compare_max = mappings.select{|item| item['reviewer_id'] == reviewer_id}.max_by {|item| item['threshold']}['threshold']

                thresholds = mappings.select {|item| (item['reviewer_id'] != reviewer_id) && (item['threshold'] > compare_max) }&.map {|item| item['threshold']}

                if thresholds.empty?
                  my_max = nil
                else
                  my_min = thresholds.min
                end
                lurms_update = level.level_user_reviewer_mappings.where(user_id: user_id, reviewer_id: reviewer_id)
                lurms_update.each do |lu|
                  result_updated << {"policy_id" => policy.id, "level_id" => level.id, "reviewer_id" => lu.reviewer_id, "max" => my_max, "min" => my_min, "exception" => lu.exception, "wo_exception" => lu.wo_exception, "user_id" => lu.user_id }
                end
                lurms_update.update_all(min: my_min, max:my_max)
              end
            end
          end
        end
      end
    end
  end

  def result_one
    file = File.open("#{file_url}result_destroyed.json", "w")
    file.write(result_destroyed.to_json.to_s)
    file.close

    file = File.open("#{file_url}result_updated.json", "w")
    file.write(result_updated.to_json.to_s)
    file.close
  end

  def migrate_dlrm
    document_types = [{"document_name" => "Report", "status_field" => "report_status_id", "user_attribute": "user_id"},
                      {"document_name" => "MoneyRequest", "status_field" => "status_id", "user_attribute": "user_id"},
                      {"document_name" => "TravelRequest", "status_field" => "status_id", "user_attribute": "user_id"},
                      {"document_name" => "BankPaymentRequest", "status_field" => "status_id", "user_attribute": "owner_id"},
                      {"document_name" => "PurchaseRequest", "status_field" => "purchase_request_status_id", "user_attribute": "creator_id"},
                      {"document_name" => "PurchaseOrder", "status_field" => "purchase_order_status_id", "user_attribute": "user_id"},
                      {"document_name" => "Invoice", "status_field" => "invoice_status_id", "user_attribute": "created_by_user_id"}]

    document_types.each do |row|
      sql = "#{row["status_field"]} IN (1,2)"
      documents = row["document_name"].constantize.where(sql)
      documents.each do |document|
        dlrms = document.dlrms
        next if dlrms.blank?
        dlrms.where(action_id: nil).each do |dlrm|
          level = ReviewalLevel.find(dlrm.level_id)
          next if level.blank?
          #check lurm present_for_the user
          user_attribute = document.send(row[:"user_attribute"])
          lurm = level.level_user_reviewer_mappings.where(user_id: user_attribute, reviewer_id: dlrm.reviewer_id).first
          if lurm.present?
            result_dlrm <<  {"policy_id" => dlrm.policy_id, "level_id" => dlrm.level_id, "provider_name" => dlrm.provider_name, "reviewer_id" => dlrm.reviewer_id, "min" => lurm.min, "max" => lurm.max }
            dlrm.update_columns(min: lurm.min, max: lurm.max)
          else
            lrm = level.level_reviewer_mappings.where(reviewer_id: dlrm.reviewer_id).first
            if lrm.present?
              result_dlrm << {"policy_id" => dlrm.policy_id, "level_id" => dlrm.level_id, "provider_name" => dlrm.provider_name, "reviewer_id" => dlrm.reviewer_id, "min" => lrm.min, "max" => lrm.max }
              dlrm.update_columns(min: lrm.min, max: lrm.max)
            end
          end

        end
      end
    end
  end

  def result_two
    file = File.open("#{file_url}result_dlrm_updated.json", "w")
    file.write(result_dlrm.to_json.to_s)
    file.close
  end
end

