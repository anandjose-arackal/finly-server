class Admin::Masters::Macros::Contracts::Route < Reform::Form
  property :route, validates: {presence: true}
end