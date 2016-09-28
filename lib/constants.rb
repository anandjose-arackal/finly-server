module Constants
  VALID_EMAIL_FORMAT = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  # todo - remove admin after testing
  SUPERADMIN_ACCOUNTS = ['sreeram@finlytest.io', 'vivek@finlytest.io', 'veekshith@finlytest.io', 'bala@finlytest.io', 'admin@finlytest.io']

  DEFAULT_CATEGORIES = ['Education and Training', 'Travel', 'Entertainment', 'Marketing and Advertising', 'Meals', 'Office Expenses', 'Other']

  FLASH_COLORS = {alert: 'red', error: 'red', failure: 'red', success: 'green', message: 'blue', notice: 'blue'}

  WHITELISTED_EMAILS = []

  ITZCASH_MODULE = 'Finly'
end