class MakeAllModelsSoftDeletable < ActiveRecord::Migration[5.2]
  def change
    change_column :money_request_processors, :payment_file_generated_at, :datetime
    change_column :report_processor_groups, :payment_file_generated_at, :datetime

    non_existent_models = []
    ################## BELOW STEP IS BEFORE DEPLOY #######################
    # first we have to seed the seedable classes with soft deletable
    # seedable_classes = ObjectSpace.each_object(Class).select {|c| c.included_modules.include?(Seedable)}
    # seedable_classes.map! { |c| c.to_s }
    # seedable_classes.each do |model|
    #   klass = model.constantize
    #   begin
    #     unless klass.has_attribute? :deleted_at
    #       ActiveRecord::Migration.add_column klass.table_name, :deleted_at, :datetime, index: true
    #     end
    #   rescue NameError, ActiveRecord::StatementInvalid => e
    #     stack_trace = e.message
    #     e.backtrace.each do |line|
    #       stack_trace += "\n#{line}"
    #     end
    #     non_existent_models << {"Class": model, "Reason": stack_trace}
    #   end
    # end
    ################## ABOVE STEP IS BEFORE DEPLOY ########################

    models = ApplicationRecord.connection.tables.map {|table| table.capitalize.singularize.camelize}
    models.each do |model|
      begin
        klass = model.constantize
        unless klass.has_attribute? :deleted_at
          ActiveRecord::Migration.add_column klass.table_name, :deleted_at, :datetime, index: true
        end
      rescue NameError, ActiveRecord::StatementInvalid => e
        stack_trace = e.message
        e.backtrace.each do |line|
          stack_trace += "\n#{line}"
        end
        non_existent_models << {"Class": model, "Reason": stack_trace}
      end
    end
    puts non_existent_models
  end
end
