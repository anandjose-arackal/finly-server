# create multiple sub-budgets for a particuler parent budget using excel
# 
class Budgets::ProcessTemplateFile < Budgets::Base

  attr_accessor :file,
                :parsed_data,
                :item_details,
                :headers,
                :valid,
                :contents,
                :validate_operation,
                :company,
                :user_id,
                :error_data,
                :budget,
                :parent_id,
                :show_excel

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or params[:file].blank?
      add_message :error, 'Error loading file. File not uploaded correctly'
      return
    end

    params[:include_children] = true
    all_budgets = Budgets::Index.(user, params)
    unless all_budgets.success?
      add_message :error, all_budgets.messages[:error]
      return
    end
    id = (params[:budget_id] or params[:id])
    self.budget = all_budgets.budgets.find_by id: id

    if self.budget.blank?
      add_message :error, "Details for budget were not found."
      return
    end

  end

  def init
    self.file = params[:file]
    headers = [:budget_name, :amount, :start_date, :end_date, :categories, :departments, :locations, :expense, :payment, :purchase_order]
    begin
      self.parsed_data = ImportUtil.load_spreadsheet(file, headers, {skip_empty_lines: true})
    rescue Ole::Storage::FormatError => e
      add_message :error, "File Format error. Please re-save your Excel sheet in 2007 format or greater."
    end
    self.valid = true
    self.error_data = []
    self.company = user.company
    self.user_id = user.id
    self.contents = []
    self.parent_id = budget.id
    self.show_excel = false

  end

  def validate
    if parsed_data.blank?
      add_message :error, 'Nothing to process'
      return
    end
  end

  def pre_process
    self.validate_operation = Budgets::BulkValidateFileData.(user, {item_details: self.parsed_data})
    binding.pry
    if validate_operation.success?

    else
      self.contents = validate_operation.contents
      self.headers = validate_operation.headers
      self.show_excel = true
      add_message :error, "Some of the budgets have errors, please check the downloaded file to resolve them"
      return
    end
  end

  def process
    self.validate_operation.item_details.each_with_index do |item, index|
      item[:budget] = {}

      item[:budget][:parent_id] = self.parent_id
      item[:budget][:name] = item[:budget_name]
      item[:budget][:start_date] = item[:start_date]
      item[:budget][:end_date] = item[:end_date]
      item[:budget][:expense] = !!StringUtils.to_bool(item[:expense])
      item[:budget][:payment] = !!StringUtils.to_bool(item[:payment])
      item[:budget][:purchase_order] = !!StringUtils.to_bool(item[:purchase_order])
      item[:budget][:budget_amount_attributes] = {value: item[:amount], currency_id: 1}

      item[:budget][:budget_criteria_mappings_attributes] = []
      if item[:categories].present?
        entities = item[:categories].split(",").map {|entity| entity.strip.to_i if entity.strip.present?}.compact #array of ids supplied in excel
        entities.each do |entity|
          item[:budget][:budget_criteria_mappings_attributes] << {budgetable_id: entity, budgetable_type: "Category"}
        end
      end

      if item[:departments].present?
        entities = item[:departments].split(",").map {|entity| entity.strip.to_i if entity.strip.present?}.compact
        entities.each do |entity|
          item[:budget][:budget_criteria_mappings_attributes] << {budgetable_id: entity, budgetable_type: "Department"}
        end
      end

      if item[:locations].present?
        entities = item[:locations].split(",").map {|entity| entity.strip.to_i if entity.strip.present?}.compact
        entities.each do |entity|
          item[:budget][:budget_criteria_mappings_attributes] << {budgetable_id: entity, budgetable_type: "BranchLocation"}
        end
      end

      # budget = self.company.budgets.build(item[:budget])

      # budget.user_id = self.user_id

      # if budget.valid?
      #   budget.save
      #   item.delete(:budget)
      #   self.contents << item.values
      # else
      #   item.delete(:budget)
      #   item[:errors] = budget.errors.full_messages
      #   self.contents << item.values
      #   self.valid = false
      #   self.show_excel = true
      # end

      op = Budgets::Create.(user, item)
      unless op.success?
        item.delete(:budget)
        item[:errors] = op.messages[:error]
        self.contents << item.values
        self.valid = false
        self.show_excel = true
      else
        budget.save
        item.delete(:budget)
        self.contents << item.values
      end
    end

    unless self.valid
      add_message :error, "Some of the budgets could not be created. Please check the downloaded file to resolve them."
    end
  end

  def post_process
    add_message :success, "Succesfully processed file."
  end

  # this method should create the temporary file that can be linked in the front end
  def failure
    if show_excel
      params[:content] = self.contents
      result = Budgets::GenerateSampleFile.(user, params)

      if result.success?
        params[:result_file_path] = result.xlsx_exporter.export_file_path
        Budgets::ProcessTemplateFile::FailurePresenter.new(user, params, messages)
      else
        add_message :error, "Some Internal Error Occurred"
      end
    else
      params[:show_excel] = self.show_excel
      Budgets::ProcessTemplateFile::FailurePresenter.new(user, params, messages)
    end
  end

  class Budgets::ProcessTemplateFile::FailurePresenter < BaseOperation::BasePresenter::FailurePresenter

    attr_accessor :result_file_path

    def init
      self.result_file_path = params[:result_file_path] if !!params[:result_file_path]
    end
  end

end
