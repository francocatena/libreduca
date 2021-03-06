class Login < ActiveRecord::Base
  # Default order
  default_scope -> { order("#{table_name}.created_at ASC") }

  # Validations
  validates :ip, :user, presence: true
  validates :ip, length: { maximum: 255 }, allow_nil: true, allow_blank: true

  # Relations
  belongs_to :user

  def to_s
    "#{self.user} -> #{self.ip}"
  end
end
