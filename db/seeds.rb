# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)




def random(low, high)
  rand * (high - low) + low
end

def random_integer(low, high)
  random(low, high).to_i
end

def random_string_of_numbers(length)
  (0...length).map { (48 + rand(10)).chr }.join
end

def random_mobile_number
  pattern = '[789]\d{9}'
  StringRandom.random_regex(pattern)
end

ExportField.seed_data

if UserRole.count == 0
  UserRole.create id: 1, name: 'Admin'
  UserRole.create id: 2, name: 'Finance Manager'
  UserRole.create id: 3, name: 'Manager'
  UserRole.create id: 4, name: 'Employee'
  UserRole.create id: 5, name: 'Auditor'
end

# if ReportStatus.count == 0
#   ReportStatus.create(id: 1, name: 'Open', order: 1)
#   ReportStatus.create(id: 2, name: 'Processing', order: 3)
#   ReportStatus.create(id: 3, name: 'Retracted', order: 2)
#   ReportStatus.create(id: 4, name: 'Rejected', order: 4)
#   ReportStatus.create(id: 5, name: 'Approved', order: 5)
#   ReportStatus.create(id: 6, name: 'Settled', order: 6)
#   ReportStatus.create(id: 7, name: 'Settlement Confirmed', order: 7)
#   ReportStatus.create(id: 8, name: 'Closed', order: 8)
# end

# if ReportTrackingAction.count == 0
#   ReportTrackingAction.create id: 1, name: 'Create'
#   ReportTrackingAction.create id: 2, name: 'Retract'
#   ReportTrackingAction.create id: 3, name: 'Submit'
#   ReportTrackingAction.create id: 4, name: 'Approve'
#   ReportTrackingAction.create id: 5, name: 'Auto Approve'
#   ReportTrackingAction.create id: 6, name: 'Reject'
#   ReportTrackingAction.create id: 7, name: 'Unapprove'
#   ReportTrackingAction.create id: 8, name: 'Take Control'
#   ReportTrackingAction.create id: 9, name: 'Settled'
#   ReportTrackingAction.create id: 10, name: 'Settlement Confirmed'
#   ReportTrackingAction.create id: 11, name: 'Closed'
# end
#
if NotificationType.count == 0
  NotificationType::VALUES.each do |k, v|
    NotificationType.create id: v, name: k
  end
end

if NotificationActionType.count == 0
  NotificationActionType::VALUES.each do |k, v|
    NotificationActionType.create id: v, name: k
  end
end
#
if ReportCommentAction.count == 0
  ReportCommentAction::ACTIONS.each do |key, value|
    ReportCommentAction.create id: value, name: key
  end
end

if MoneyRequestCommentAction.count == 0
  MoneyRequestCommentAction::ACTIONS.each do |key, value|
    MoneyRequestCommentAction.create id: value, name: key
  end
end

if MoneyRequestTrackingAction.count == 0
  MoneyRequestTrackingAction::ACTIONS.each do |key, value|
    MoneyRequestTrackingAction.create id: value, name: key
  end
end


# if MoneyRequestStatus.count == 0
#   MoneyRequestStatus::VALUES.each do |key, value|
#     name = key.to_s
#     name[0] = name[0].capitalize
#     order = MoneyRequestStatus.order_for_id(value)
#     MoneyRequestStatus.create id: value, name: name, order: order
#   end
# end

if PaymentMode.count == 0
  PaymentMode::MODES.each do |key, value|
    PaymentMode.create id: value, name: key
  end
end

if State.count == 0
  State::STATES.each do |item|
    State.create code: item[:code], name: item[:name]
  end
end

if NotifierType.count == 0
  NotifierType::ACTIONS.each do |item|
    NotifierType.create id: (NotifierType::ACTIONS.find_index(item) + 1), name: item[:key].to_s,
                        has_push_notification: item[:has_push_notification], has_mailer: item[:has_mailer],
                        configurable_push_notification: item[:configurable_push_notification],
                        configurable_mailer: item[:configurable_mailer]
  end
end

if Currency.count == 0
  Currency.seed_data
end

if ExpenseType.count ==0
  ExpenseType.create(id: 1, name: "Manual")
  ExpenseType.create(id: 2, name: "Card")
  ExpenseType.create(id: 3, name: "Distance")
  ExpenseType.create(id: 4, name: "Time")
  ExpenseType.create(id: 5, name: "Per Diem")
end

# if ExpenseStatus.count ==0
#   ExpenseStatus.create(id: 1, name: "Unreported", order: 1)
#   ExpenseStatus.create(id: 2, name: "Unsubmitted", order: 2)
#   ExpenseStatus.create(id: 3, name: "Submitted", order: 3)
#   ExpenseStatus.create(id: 4, name: "Rejected", order: 4)
#   ExpenseStatus.create(id: 5, name: "Cancelled", order: 5)
# end

if ExpenseRuleType.count == 0
  ExpenseRuleType.create!(name: "Require Receipt")
  ExpenseRuleType.create!(name: "Require Note")
  ExpenseRuleType.create!(name: "Disallow Expense")
end

if RuleType.count == 0
  RuleType.create!(name: "Warning")
  RuleType.create!(name: "Blocking")
end

Period.seed_data

# if PaymentType.count == 0
#   PaymentType::TYPES.each do |key, value|
#     PaymentType.create id: value, name: key
#   end
# end

if CardType.count == 0
  CardType.create(id: 1, name: 'Physical')
  CardType.create(id: 2, name: 'Virtual')
end


if MccGroup.count == 0
  MccGroup::CODE_MAP.each do |key, value|
    MccGroup.create(id: key, code: value[:code], name: value[:name])
  end
end

if ChannelType.count == 0
  ChannelType::TYPES.each do |k, v|
    ChannelType.create(name: ChannelType::NAMES[v], abbreviation: k.to_s.upcase)
  end
end

if OtpRequestType.count == 0
  OtpRequestType::TYPES.each do |k, v|
    OtpRequestType.create(id: v, name: k)
  end
end

if FieldParentType.count == 0
  FieldParentType::TYPES.each do |key, value|
    FieldParentType.create id: value, name: key
  end
end

if FieldType.count == 0
  FieldType::TYPES.each do |key, value|
    FieldType.create id: value, name: key
  end
end

if PhysicalUnit.count == 0
  PhysicalUnit::VALUES.each do |k, v|
    PhysicalUnit.create(id: k, name: v[:name], symbol: v[:symbol])
  end
end

CardProgram.seed_data

FeedbackType.seed_data

PaymentPurpose.seed_data

PaymentOrderStatus.seed_data

SystemMessageType.seed_data

ItzCashCardProgram.seed_data

CompanyType.seed_data

InvoiceNumberConfigType.seed_data

# PinCodeCityIdMapping.seed_data

# CityIdCityCodeMapping.seed_data

# ItzCashDmtBeneficiaryType.seed_data

# ItzCashDmtBeneficiaryStatus.seed_data
Purpose.seed_data

AdminUserRole.seed_data

CardStatus.seed_data

CardAssignRequestStatus.seed_data

CardAssignRequestTrackAction.seed_data

TransactionStatus.seed_data
TransactionType.seed_data

if AdminUser.count == 0
  # creating admin panel users who can access admin panel
  AdminUser.create!(email: 'admin@demo.io', password: 'demo1234', password_confirmation: 'demo1234', mobile_number: random_mobile_number,
                    admin_user_role_mappings_attributes: [{admin_user_role_id: AdminUserRole.id_for(:admin)}, {admin_user_role_id: AdminUserRole.id_for(:transcriber)},
                                                          {admin_user_role_id: AdminUserRole.id_for(:verifier)}])
  AdminUser.create!(email: 'sreeram@demo.io', password: 'demo1234', password_confirmation: 'demo1234', mobile_number: random_mobile_number,
                    admin_user_role_mappings_attributes: [{admin_user_role_id: AdminUserRole.id_for(:admin)}, {admin_user_role_id: AdminUserRole.id_for(:transcriber)},
                                                          {admin_user_role_id: AdminUserRole.id_for(:verifier)}])
  AdminUser.create!(email: 'vivek@demo.io', password: 'demo1234', password_confirmation: 'demo1234', mobile_number: random_mobile_number,
                    admin_user_role_mappings_attributes: [{admin_user_role_id: AdminUserRole.id_for(:itzcash_verifier)}])
  AdminUser.create!(email: 'veekshith@demo.io', password: 'demo1234', password_confirmation: 'demo1234', mobile_number: random_mobile_number,
                    admin_user_role_mappings_attributes: [{admin_user_role_id: AdminUserRole.id_for(:itzcash_operations)}])
  AdminUser.create!(email: 'abinash@demo.io', password: 'demo1234', password_confirmation: 'demo1234', mobile_number: random_mobile_number,
                    admin_user_role_mappings_attributes: [{admin_user_role_id: AdminUserRole.id_for(:itzcash_operations)}])
end

# temporary otp verification all numbers in db
User.all.each do |user|
  user.otp_confirm
  user.update verified: true
end

# if FieldConfiguration.count == 0
#   # Report custom fields
#   CustomField::Configuration::Create.(User.first, field_configuration: {configurable_type: 'Company',
#                                                                         configurable_id: 1, company_id: 1,
#                                                                         field_name: 'Employee ID',
#                                                                         global: true,
#                                                                         field_type_id: FieldType.id_for(:text),
#                                                                         mandatory: false,
#                                                                         field_parent_type_id: FieldParentType.id_for(:report)})
#   # Report mandatory custom field
#   CustomField::Configuration::Create.(User.first, field_configuration: {configurable_type: 'Policy',
#                                                                         configurable_id: 1, company_id: 1,
#                                                                         field_name: 'Client Name',
#                                                                         global: true,
#                                                                         field_type_id: FieldType.id_for(:text),
#                                                                         mandatory: false,
#                                                                         field_parent_type_id: FieldParentType.id_for(:report)})
#
#   # Money Request custom fields
#   CustomField::Configuration::Create.(User.first, field_configuration: {configurable_type: 'Policy',
#                                                                         configurable_id: 1, company_id: 1,
#                                                                         field_name: 'Client Location',
#                                                                         global: true,
#                                                                         field_type_id: FieldType.id_for(:text),
#                                                                         mandatory: false,
#                                                                         field_parent_type_id: FieldParentType.id_for(:money_request)})
#   # Money Request mandatory custom field
#   CustomField::Configuration::Create.(User.first, field_configuration: {configurable_type: 'Policy',
#                                                                         configurable_id: 1, company_id: 1,
#                                                                         field_name: 'Project Name',
#                                                                         global: true,
#                                                                         field_type_id: FieldType.id_for(:text),
#                                                                         mandatory: false,
#                                                                         field_parent_type_id: FieldParentType.id_for(:money_request)})
#
#   # Manual Expense custom fields
#   CustomField::Configuration::Create.(User.first, field_configuration: {configurable_type: 'Company',
#                                                                         configurable_id: 1, company_id: 1,
#                                                                         field_name: 'Location',
#                                                                         global: true,
#                                                                         field_type_id: FieldType.id_for(:text),
#                                                                         mandatory: false,
#                                                                         field_parent_type_id: FieldParentType.id_for(:manual_expense)})
#   # Manual Expense mandatory custom field
#   CustomField::Configuration::Create.(User.first, field_configuration: {configurable_type: 'Company',
#                                                                         configurable_id: 1, company_id: 1,
#                                                                         field_name: 'Duration of Meeting',
#                                                                         global: true,
#                                                                         field_type_id: FieldType.id_for(:text),
#                                                                         mandatory: false,
#                                                                         field_parent_type_id: FieldParentType.id_for(:manual_expense)})
#
#   # Distance Expense custom fields
#   CustomField::Configuration::Create.(User.first, field_configuration: {configurable_type: 'Company',
#                                                                         configurable_id: 1, company_id: 1,
#                                                                         field_name: 'Reason',
#                                                                         global: true,
#                                                                         field_type_id: FieldType.id_for(:text),
#                                                                         mandatory: false,
#                                                                         field_parent_type_id: FieldParentType.id_for(:distance_expense)})
#   # Distance Expense mandatory custom field
#   CustomField::Configuration::Create.(User.first, field_configuration: {configurable_type: 'Company',
#                                                                         configurable_id: 1, company_id: 1,
#                                                                         field_name: 'Client Name',
#                                                                         global: true,
#                                                                         field_type_id: FieldType.id_for(:text),
#                                                                         mandatory: false,
#                                                                         field_parent_type_id: FieldParentType.id_for(:distance_expense)})
#
#   # Time Expense custom fields
#   CustomField::Configuration::Create.(User.first, field_configuration: {configurable_type: 'Company',
#                                                                         configurable_id: 1, company_id: 1,
#                                                                         field_name: 'Reason',
#                                                                         global: true,
#                                                                         field_type_id: FieldType.id_for(:text),
#                                                                         mandatory: false,
#                                                                         field_parent_type_id: FieldParentType.id_for(:time_expense)})
#   # Time Expense mandatory custom field
#   CustomField::Configuration::Create.(User.first, field_configuration: {configurable_type: 'Company',
#                                                                         configurable_id: 1, company_id: 1,
#                                                                         field_name: 'Client Name',
#                                                                         global: true,
#                                                                         field_type_id: FieldType.id_for(:text),
#                                                                         mandatory: false,
#                                                                         field_parent_type_id: FieldParentType.id_for(:time_expense)})
#   # Per Diem Expense custom fields
#   CustomField::Configuration::Create.(User.first, field_configuration: {configurable_type: 'Company',
#                                                                         configurable_id: 1, company_id: 1,
#                                                                         field_name: 'Reason',
#                                                                         global: true,
#                                                                         field_type_id: FieldType.id_for(:text),
#                                                                         mandatory: false,
#                                                                         field_parent_type_id: FieldParentType.id_for(:per_diem_expense)})
#   # Per Diem Expense mandatory custom field
#   CustomField::Configuration::Create.(User.first, field_configuration: {configurable_type: 'Company',
#                                                                         configurable_id: 1, company_id: 1,
#                                                                         field_name: 'Client Name',
#                                                                         global: true,
#                                                                         field_type_id: FieldType.id_for(:text),
#                                                                         mandatory: false,
#                                                                         field_parent_type_id: FieldParentType.id_for(:per_diem_expense)})
# end


# if CardTransaction.filter_refunds(1).count == 0
#   User.all.each do |user|
#     next unless user.cards.present?
#     card = user.cards.first
#     10.times do
#
#       trans_types = ["Credit"]
#       trans_modes = ["null"]
#       from_date = DateTime.parse("01-01-2017 12:00:00")
#       to_date = DateTime.now
#       random_amount = random_integer(50, 200) + 0.1234
#       sample_msg_queue_entry = "321744RUPP0003508886000#{random_string_of_numbers(7)},#{from_date + (to_date - from_date)*rand},#{random_amount},#{random_amount + random(5, 10)},173244,#{trans_modes[0]},OLCDCB_POSOFFUS,Refund #{Faker::University.name},91,#{trans_types[0]},#{card.proxy},RBLRUP"
#
#       data = sample_msg_queue_entry.split(",")
#
#       # for the split between merchant city and merchant name
#       name_city = data[7].split("\t") # splits the sixth field after the comma into name and city
#       merchant_name = name_city[0]
#       merchant_city = name_city[1]
#
#       trans_params = {reference_id: data[0],
#                       transaction_timestamp: data[1],
#                       transaction_amount_attributes: {value: data[2], currency_id: 1},
#                       billing_amount_attributes: {value: data[3], currency_id: 1},
#                       auth_transaction_id: data[4],
#                       transaction_mode: data[5],
#                       itzcash_merchant_key: data[6],
#                       merchant_name: merchant_name,
#                       merchant_city: merchant_city,
#                       response_code: data[8],
#                       transaction_type: data[9],
#                       serial_id: data[10],
#                       product_code: data[11]
#       }
#
#       result = Card::Transaction::Create.(trans_params)
#     end
#   end
# end

# creating junk payment order data
# 10.times do
#   # create a bank account first
#   vendor = YesBankVendor.create(name: "Seomthing", company_id: 1)
#   ba1 = vendor.bank_accounts.create(account_number: random_string_of_numbers(8),
#                                  ifsc: random_string_of_numbers(7),
#                                  name: "Sreeram")
#   ba2 = vendor.bank_accounts.create(account_number: random_string_of_numbers(8),
#                                          ifsc: random_string_of_numbers(7),
#                                          name: "Sreeram Two")
#   p = PaymentOrder.create(payment_purpose_id: PaymentPurpose.id_for(:vendor_payment),
#                       initiating_user: User.first,
#                       receiving_account_type: "BankAccount",
#                       amount_requested_attributes: {value: 2000, currency_id: 1},
#                       currency_id: 1,
#                       amount_processed_attributes: {value: 2000, currency_id: 1},
#                       payment_order_status_id: random_integer(1, 7),
#                       company_id: 1,
#                       payments_attributes: [
#                           {
#                               date: Date.today,
#                               payment_status_id: random_integer(1, 7),
#                               initiating_user: User.first,
#                               receiving_user: vendor,
#                               receiving_account: ba1,
#                               payment_type_id: PaymentType.id_for(:credit),
#                               initiating_account: Company.first.yes_bank_company_account,
#                               payment_purpose_id: PaymentPurpose.id_for(:vendor_payment),
#                               amount_attributes: {
#                                   value: 1000,
#                                   currency_id: 1
#                               }
#
#                           },
#                           {
#                               date: Date.today,
#                               payment_status_id: random_integer(1, 7),
#                               initiating_user: User.first,
#                               receiving_user: vendor,
#                               receiving_account: ba2,
#                               payment_type_id: PaymentType.id_for(:credit),
#                               initiating_account: Company.first.yes_bank_company_account,
#                               payment_purpose_id: PaymentPurpose.id_for(:vendor_payment),
#                               amount_attributes: {
#                                   value: 1000,
#                                   currency_id: 1
#                               }
#                           }
#                       ]
#   )
#
# end

# Expense.all.each do |expense|
#   expense.update_other_currencies
# end
# Seed All Seedable classes
seedable_classes = ObjectSpace.each_object(Class).select { |c| c.included_modules.include?(Seedable) }

seedable_classes.each do |seedable_class|
  # next if ['AdminReviewWorkflow'].include? seedable_class.name
  if seedable_class.respond_to?(:as_hash)
    seedable_class.seed_data
  end
end

############## Seeding payment processor related classes ##############
PaymentStatus.seed_data
BankTransferStatus.seed_data
Purpose.seed_data
BankAccountProvider.seed_data
AdminReviewWorkflow.seed_data
PaymentType.seed_data

