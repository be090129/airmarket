class Listing < ActiveRecord::Base
  belongs_to :user
  has_many :orders
  accepts_nested_attributes_for :orders, :allow_destroy => true

  has_many :images, :dependent => :destroy
  accepts_nested_attributes_for :images, :reject_if => lambda { |t| t['photo'].nil? }, allow_destroy: true



end
