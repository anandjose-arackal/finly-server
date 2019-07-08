class Budgets::BulkValidateFileData < Budgets::Base

  attr_accessor :item_details, :error_messages, :valid, :contents, :headers,
                :issues, :issue_item, :all_budgets, :all_budget_ids,
                :all_categories, :all_departments, :all_vendors, :all_locations

  class Budgets::BulkValidateFileData::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :contents, :headers, :item_details, :issues

    def init
      self.contents = params[:contents]
      self.headers = params[:headers]
      self.item_details = params[:item_details]
      self.issues = params[:issues]
    end

  end

  class Budgets::BulkValidateFileData::FailurePresenter < BaseOperation::BasePresenter::FailurePresenter

    attr_accessor :contents, :headers, :issues

    def init
      self.contents = params[:contents]
      self.headers = params[:headers]
      self.issues = params[:issues]
    end
  end

  def init
    self.item_details = params[:item_details]
    self.contents = []
    self.headers = retrieve_header_names
    # setting the valid as true here, so that even if one line item failed in the
    # below validations it will return false
    self.valid = true

    self.issues = []
    company = user.company
    self.all_budgets = company.budgets
    self.all_categories = company.categories
    self.all_departments = company.departments
    self.all_vendors = company.yes_bank_vendors
    self.all_locations = company.locations

  end

  def validate
  end

  def pre_process
    self.all_budget_ids = self.all_budgets.pluck(:id) rescue []
  end

  def process
    self.item_details.each do |item|
    	parent_budget_id = item[:parent_budget_id] || item["parent_budget_id"]
    	budget_name = item[:budget_name] || item["budget_name"]
    	amount = item[:amount] || item["amount"]
    	start_date = item[:start_date] || item["start_date"]
    	end_date = item[:end_date] || item["end_date"]
    	users = item[:users] || item["users"]
    	categories = item[:categories] || item["categories"]
    	departments = item[:departments] || item["departments"]
    	locations = item[:locations] || item["locations"]
    	vendors = item[:vendors] || item["vendors"]
    	expense = item[:expense] || item["expense"]
    	payment = item[:payment] || item["payment"]
    	purchase_order = item[:purchase_order] || item["purchase_order"]

      self.error_messages = []
      self.issue_item = {}

      if parent_budget_id.present?
      	if ( self.all_budget_ids.present? and (self.all_budget_ids.exclude? parent_budget_id) ) or self.all_budget_ids.blank?
      		self.valid = false
      		self.error_messages << "Specified parent budget does not exist for this company."
      		self.issue_item[:parent_budget_id] = "Specified parent budget does not exist for this company."
      	end
      end

      if budget_name.blank?
        self.valid = false
        self.error_messages << "Name of the budget cannot be blank"
        self.issue_item[:budget_name] = "Name of the budget cannot be blank"
      end

      unless validate_amount amount
        self.valid = false
        self.error_messages << "Budget amount is invalid."
        self.issue_item[:amount] = "Budget amount is invalid."
      end

      if start_date.blank? || validate_date(start_date)
        self.valid = false
        self.error_messages << "Start date of the budget looks invalid."
        self.issue_item[:start_date] = "Start of date the budget looks invalid."
      end

      if end_date.blank? || validate_date(end_date)
        self.valid = false
        self.error_messages << "End date of the budget looks invalid."
        self.issue_item[:end_date] = "End of date the budget looks invalid."
      end

      if users.blank? and categories.blank? and departments.blank? and locations.blank? and vendors.blank?
      	self.valid = false
      	self.error_messages << "Atlease one budget criteria needs to be specified"
      	self.issue_item[:users] = self.issue_item[:categories] = self.issue_item[:departments] = self.issue_item[:locations] = self.issue_item[:vendors] = "Atlease one budget criteria needs to be specified"
      end

      # categories.split(",").map(&:strip)
      # self.all_category_ids





      if valid

      end

      item[:errors] = self.error_messages.to_sentence if self.error_messages.present?

      self.contents << item.values

      self.issues << self.issue_item
    end
  end

  def success?
    self.valid
  end

  def failure?
    self.valid
  end

  def success
    params[:contents] = self.contents
    params[:headers] = self.headers
    params[:item_details] = self.item_details
    params[:issues] = self.issues
    Budgets::BulkValidateFileData::SuccessPresenter.new(user, params, messages)
  end

  def failure
    params[:contents] = self.contents
    params[:headers] = self.headers
    params[:issues] = self.issues
    Budgets::BulkValidateFileData::FailurePresenter.new(user, params, messages)
  end


  private

  def validate_amount(amount)
    if amount.blank? || (!/\A\d+\.\d+\z/.match(amount) && !/\A\d+\z/.match(amount)) # check if blank or not a positive float or not a positive integer
      return false
    end
    true
  end

  def validate_date(date)
    date_obj = Date.parse(date) rescue nil
    if date_obj.blank?
      return false
    end
    true
  end

  def retrieve_header_names
    [
	    "Parent Budget ID (optional)",
	    "Budget Name",
	    "Amount",
	    "Start Date (dd-mm-yyyy)",
	    "End Date (dd-mm-yyyy)",
	    "Users Budgetable",
	    "Categories Budgetable ",
	    "Departments Budgetable",
	    "Locations Budgetable",
	    "Vendors Budgetable",
	    "Expense? (Y/N)",
	    "Payment? (Y/N)",
	    "Purchase Order? (Y/N)"
    ]
  end

end