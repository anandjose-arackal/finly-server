module Constants
  VALID_EMAIL_FORMAT = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  VALID_MOBILE_NUMBER = /\A(?:(?:\+|0{0,2})91(\s*[\-]\s*)?|[0]?)?[789]\d{9}\z/i
  VALID_PIN_CODE = /\A[1-9][0-9]{5}\z/i
  VALID_GENDER = /[MmFf]/i

  # todo - remove admin after testing
  SUPERADMIN_ACCOUNTS = ['sreeram@finlytest.io', 'vivek@finlytest.io', 'veekshith@finlytest.io', 'bala@finlytest.io', 'admin@finlytest.io']

  DEFAULT_CATEGORIES = ['Education and Training', 'Travel', 'Entertainment', 'Marketing and Advertising', 'Meals', 'Office Expenses', 'Other']

  FLASH_COLORS = {alert: 'red', error: 'red', failure: 'red', success: 'green', message: 'blue', notice: 'blue'}

  WHITELISTED_EMAILS = []


  class Constants::ItzCash

    MODULE = 'Finly'

  end
end