require_relative 'abstract_adapter'
module FinlyIntegrations
  module Adapters
    class QuickbooksAdapter < AbstractAdapter
      ADAPTER_NAME ||= :quickbooks
      CATEGORY_LINE_ITEMS_MAPPER ||= {
          QuickbooksFinlyIntegrationsCategory::QUICKBOOKS_CATEGORY_SUB_TYPES[0] => ['AccountBasedExpenseLineDetail', :account_based_expense!],
          QuickbooksFinlyIntegrationsCategory::QUICKBOOKS_CATEGORY_SUB_TYPES[1] => ['ItemBasedExpenseLineDetail', :item_based_expense!],
      }
      PAYMENT_TYPES_MAPPER ||= {
          reimbursable: "Cash",
          non_reimbursable: "CreditCard"
      }

      def setup_connection(auth_obj)
        @access_token = OAuth::AccessToken.new(QB_OAUTH_CONSUMER, auth_obj.token, auth_obj.secret)
        @company_id = auth_obj.uid
        @finly_company_id = auth_obj.user.company_id
        @finly_company = auth_obj.user.company
        @finly_user_id = auth_obj.user_id
        @quickbooks_config = QuickbooksConfiguration.where(user_id: auth_obj.user_id).first
        service = Quickbooks::Service::CompanyInfo.new
        initialize_service(service)
        company_info = service.query
        @error_logger = Logger.new("#{Rails.root}/log/quickbooks_errors.log")
        @payroll_enabled = false
        company_info.entries.first.name_values.each do |name_value|
          if name_value.name == 'PayrollFeature'
            @payroll_enabled = (name_value.value == 'true')
            break
          end
        end
      end

      def categories(updated_at = nil)
        categories = []
        categories += accounts(updated_at)
        categories += items(updated_at)
        categories
      end

      def save_report(qb_report)
        finly_purchase = Quickbooks::Model::Purchase.new
        finly_purchase.account_id = qb_report.payment_type_quickbooks_id(qb_report.reimbursable)
        finly_purchase.payment_type = ( qb_report.reimbursable ? "Cash" : "CreditCard" )
        finly_purchase.txn_date = qb_report.date
        qb_report.expenses.not_synced_with_quickbooks.each do |expense|
          category = expense.category
          if category.nil? || category.quickbooks_category.nil?
            return "Expense at #{expense.merchant_name} doesn't belong to a Quickbooks category. Please update the expenses and try again"
          end
          if category.quickbooks_category.quickbooks_integration_type.to_sym != FinlyIntegrationsConstants::ADAPTERS_LIST[0]
            return "All expenses of this report don't belong to Quickbooks. Aborting export of the report."
          end
          # because inventory items have an associated quantity
          if category.quickbooks_category.inventory_item?
            next
          end
          line_item = Quickbooks::Model::PurchaseLineItem.new
          line_item.description = "#{expense.merchant_name} - #{expense.note}"
          line_item.amount = expense.amount.send(:INR).to_f
          line_item.detail_type = CATEGORY_LINE_ITEMS_MAPPER[category.quickbooks_category.quickbooks_category_type][0]

          # deciding whether it's an account item or a purchase item
          line_item.send(CATEGORY_LINE_ITEMS_MAPPER[category.quickbooks_category.quickbooks_category_type][1]) do |detail|
            if category.quickbooks_category.quickbooks_category_type == QuickbooksFinlyIntegrationsCategory::QUICKBOOKS_CATEGORY_SUB_TYPES[0]
              detail.account_id = category.quickbooks_category.quickbooks_id
            else
              detail.item_id = category.quickbooks_category.quickbooks_id
            end
          end


          finly_purchase.line_items << line_item
        end
        # mapping the department and payee details (called entity) from the qb_report
        # to sync it in quickbooks
        finly_purchase.department_id = qb_report.quickbooks_department_id
        finly_purchase.entity_id = qb_report.user.quickbooks_user&.quickbooks_id

        purchase_service = Quickbooks::Service::Purchase.new
        begin
          initialize_service(purchase_service)
          created_purchase = purchase_service.create(finly_purchase)
          qb_report.expenses.update_all(synced_with_quickbooks: true)

          puts "Created Report in Quickbooks!"

          return true
        rescue => error
          @error_logger.error("Sync of report: #{qb_report.report.name} because of the following error: #{error.message}")
          error.backtrace.each do |line|
            @error_logger.error "\t #{line}"
          end
          return "Sync with Quickbooks failed. Please contact your account manager for further assistance"
        end

      end

      def accounts(updated_at = nil)
        accounts = []
        account_service = Quickbooks::Service::Account.new
        retrieve_all_in_batches accounts, account_service, method(:quickbooks_account_mapper), updated_at
        accounts
      end

      def items(updated_at = nil)
        items = []
        item_service = Quickbooks::Service::Item.new
        retrieve_all_in_batches items, item_service, method(:quickbooks_item_mapper), updated_at
        items
      end

      def users(updated_at = nil)
        users = []
        users += employees(updated_at)
        users += vendors(updated_at)
      end

      def employees(updated_at = nil)
        employees = []
        service = Quickbooks::Service::Employee.new
        retrieve_all_in_batches employees, service, method(:quickbooks_employee_mapper), updated_at
        employees
      end

      def vendors(updated_at=nil)
        vendors = []
        service = Quickbooks::Service::Vendor.new
        retrieve_all_in_batches vendors, service, method(:quickbooks_vendor_mapper), updated_at
        vendors
      end

      def tags(updated_at = nil)
        tags = []
        tags += classes(updated_at)
        tags += customers(updated_at)
        tags += departments(updated_at)
        tags
      end

      def classes(updated_at = nil)
        classes = []
        service = Quickbooks::Service::Class.new
        retrieve_all_in_batches classes, service, method(:quickbooks_class_mapper), updated_at
        classes
      end

      def customers(updated_at = nil)
        customers = []
        service = Quickbooks::Service::Customer.new
        retrieve_all_in_batches customers, service, method(:quickbooks_customer_mapper), updated_at
        customers
      end

      def departments(updated_at = nil)
        departments = []
        service = Quickbooks::Service::Department.new
        retrieve_all_in_batches departments, service, method(:quickbooks_department_mapper), updated_at
        departments
      end

      private

      def quickbooks_employee_mapper(user)
        # fi_user = QuickbooksFinlyIntegrationsUser.find_or_initialize_by(quickbooks_integration_type: QuickbooksFinlyIntegratable::ALLOWED_INTEGRATION_TYPES.first, quickbooks_id: user.id, quickbooks_user_type: QuickbooksFinlyIntegrationsUser::QUICKBOOKS_USER_TYPES.first)
        fi_user = QuickbooksFinlyIntegrationsUser.new({
                              email: (user.primary_email_address.address if user.primary_email_address.present?),
                              name: user.display_name,
                              quickbooks_id: user.id,
                              company_id: @finly_company_id,
                              mobile_number: (user.primary_phone.free_form_number if user.primary_phone.present?),
                              quickbooks_updated_at: user.meta_data.last_updated_time,
                              active: user.active?,
                              quickbooks_user_type: "Employee"
                                                      })
        save_additional_information(fi_user, user)
        fi_user
      end

      def quickbooks_vendor_mapper(user)
        fi_user = QuickbooksFinlyIntegrationsUser.find_or_initialize_by(quickbooks_integration_type: QuickbooksFinlyIntegratable::ALLOWED_INTEGRATION_TYPES.first, quickbooks_id: user.id, quickbooks_user_type: QuickbooksFinlyIntegrationsUser::QUICKBOOKS_USER_TYPES.last)
        fi_user.email = user.primary_email_address.address if user.primary_email_address.present?
        fi_user.name = user.display_name
        fi_user.company_id = @finly_company_id
        fi_user.mobile_number = user.primary_phone.free_form_number if user.primary_phone.present?
        fi_user.quickbooks_updated_at = user.meta_data.last_updated_time
        fi_user.active = user.active?
        save_additional_information(fi_user, user)
        fi_user
      end

      def quickbooks_account_mapper(account)
        fi_account = QuickbooksFinlyIntegrationsCategory.new
        fi_account.name = account.name
        fi_account.active = account.active?
        fi_account.quickbooks_id = account.id
        fi_account.company_id = @finly_company_id
        fi_account.quickbooks_integration_type = QuickbooksFinlyIntegratable::ALLOWED_INTEGRATION_TYPES.first
        fi_account.quickbooks_updated_at = account.meta_data.last_updated_time
        fi_account.category_sub_type = QuickbooksFinlyIntegrationsCategory::QUICKBOOKS_CATEGORY_SUB_TYPES.first
        save_additional_information(fi_account, account)
        fi_account
      end

      def quickbooks_item_mapper(item)
        fi_item = QuickbooksFinlyIntegrationsCategory.new
        fi_item.name = item.name
        fi_item.active = item.active?
        fi_item.quickbooks_id = item.id
        fi_item.company_id = @finly_company_id
        fi_item.quickbooks_integration_type = QuickbooksFinlyIntegratable::ALLOWED_INTEGRATION_TYPES.first
        fi_item.quickbooks_updated_at = item.meta_data.last_updated_time
        if item['account_type']&.upcase == 'EXPENSE'
          fi_item.category_sub_type = QuickbooksFinlyIntegrationsCategory::QUICKBOOKS_CATEGORY_SUB_TYPES.last
        end
        save_additional_information(fi_item, item)
        fi_item
      end

      def quickbooks_class_mapper(klass)
        fi_class = QuickbooksFinlyIntegrationsTag.new
        fi_class.name = klass.name
        fi_class.active = klass.active?
        fi_class.quickbooks_id = klass.id
        fi_class.company_id = @finly_company_id
        fi_class.quickbooks_integration_type = QuickbooksFinlyIntegratable::ALLOWED_INTEGRATION_TYPES.first
        fi_class.quickbooks_updated_at = klass.meta_data.last_updated_time
        fi_class.tag_sub_type = QuickbooksFinlyIntegrationsTag::QUICKBOOKS_TAG_SUB_TYPES.first
        save_additional_information(fi_class, klass)
        fi_class
      end

      def quickbooks_customer_mapper(customer)
        fi_customer = QuickbooksFinlyIntegrationsTag.new
        fi_customer.name = customer.display_name
        fi_customer.active = customer.active?
        fi_customer.quickbooks_id = customer.id
        fi_customer.company_id = @finly_company_id
        fi_customer.quickbooks_integration_type = QuickbooksFinlyIntegratable::ALLOWED_INTEGRATION_TYPES.first
        fi_customer.quickbooks_updated_at = customer.meta_data.last_updated_time
        fi_customer.tag_sub_type = QuickbooksFinlyIntegrationsTag::QUICKBOOKS_TAG_SUB_TYPES[1]
        save_additional_information(fi_customer, customer)
        fi_customer
      end

      def quickbooks_department_mapper(department)
        fi_department = QuickbooksFinlyIntegrationsDepartment.new
        fi_department.name = department.name
        fi_department.active = department.active?
        fi_department.quickbooks_id = department.id
        fi_department.company_id = @finly_company_id
        fi_department.quickbooks_integration_type = QuickbooksFinlyIntegratable::ALLOWED_INTEGRATION_TYPES.first
        fi_department.quickbooks_updated_at = department.meta_data.last_updated_time
        save_additional_information(fi_department, department)
        fi_department
      end

      def save_additional_information(finly_obj, quickbooks_obj)
        finly_obj.quickbooks_additional_information = quickbooks_obj.to_json
      end

      def retrieve_all_in_batches(container, service, obj_mapper, updated_at = nil)
        if updated_at.present?
          cdc_service = Quickbooks::Service::ChangeDataCapture.new
          initialize_service(cdc_service)
          klass = service.class.name.demodulize
          changed = cdc_service.since(Array(klass), updated_at).all_types
          create_finly_types_from_quickbooks(container, obj_mapper, changed[klass])
        else
          initialize_service(service)
          service.query_in_batches nil do |batch|
            create_finly_types_from_quickbooks(container, obj_mapper, batch)
          end
        end
      end

      def initialize_service(service)
        service.company_id = @company_id
        service.access_token = @access_token
      end

      def create_finly_types_from_quickbooks(container, obj_mapper, batch)
        batch.each do |obj|
          fi_obj = obj_mapper.call(obj)
          container << fi_obj if fi_obj.valid?
        end
      end

    end
  end
end