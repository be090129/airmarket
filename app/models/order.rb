class Order < ActiveRecord::Base
  validates :start_date, :end_date, presence: true

  belongs_to :listing
  has_many :messages

  belongs_to :buyer, class_name: "User"
  belongs_to :seller, class_name: "User"

  accepts_nested_attributes_for :messages, :allow_destroy => true

  scope :payed, -> { where('status = ?' , "Payed") }
  scope :payout, -> { where('start_date < ? AND check_payout = ?' , Date.today, false) }

  scope :expired_pending, -> { where('created_at <= ? AND status = ?' , Date.today-2, "Pending") }
  scope :expired_validated, -> { where('validated_time <= ? AND status = ?' , Date.today-2, "Validated") }

end
