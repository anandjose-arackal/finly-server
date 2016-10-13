module Constants
  VALID_EMAIL_FORMAT = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  VALID_MOBILE_NUMBER = /\A(?:(?:\+|0{0,2})91(\s*[\-]\s*)?|[0]?)?[789]\d{9}\z/i
  VALID_PIN_CODE = /\A[1-9][0-9]{5}\z/i
  VALID_GENDER = /[MmFf]/i

  # todo - remove admin after testing
  SUPERADMIN_ACCOUNTS = ['sreeram@finlytest.io', 'vivek@finlytest.io', 'veekshith@finlytest.io', 'bala@finlytest.io', 'admin@finlytest.io']

  DEFAULT_CATEGORIES = ['Education and Training', 'Travel', 'Entertainment', 'Marketing and Advertising', 'Meals', 'Office Expenses', 'Other']

  FLASH_COLORS = {alert: 'red', error: 'red', failure: 'red', success: 'green', message: 'blue', notice: 'blue'}

  WHITELISTED_EMAILS = ['manager4@finlytest.io', 'kaley@finlytest.io']

  class Constants::ItzCash

    MODULE = 'FINLY'
    MERCHANT_TYPE_KEY = 'DEFAULT_ITIL'
    # PRODUCT_CODE = 'NGPRHD'
    # CHARGE_CODE = 'GPRESC'
    TRANSACTION_TYPE_CREDIT = 1
    TRANSACTION_TYPE_DEBIT = 2
    OPERATION_TYPE_BLOCK = 'B'
    OPERATION_TYPE_UNBLOCK = 'U'

    # DUMMY_DCODE = 'D000000360'

    # G = Assigned
    # M = Material Inward
    # F = Stock Transfer
    # I = Invoiced (Activated)
    # A = Active (In Use)
    # B = Blocked
    # X = Expired
    # D = Damaged
    CARD_STATUS_CODE = {G: 'Assigned', M: 'Pending', F: 'Issued', I: 'Activated', A: 'Active', B: 'Blocked',
                        X: 'Expired', D: 'Damaged'}
  end
end