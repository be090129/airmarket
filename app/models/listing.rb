class Listing < ActiveRecord::Base

  geocoded_by :address, :latitude  => :latitude, :longitude => :longitude
  after_validation :geocode

  before_save :get_detail_listing


  belongs_to :user
  has_many :orders
  accepts_nested_attributes_for :orders, :allow_destroy => true

  has_many :images, :dependent => :destroy
  accepts_nested_attributes_for :images, :reject_if => lambda { |t| t['photo'].nil? }, allow_destroy: true

  def get_detail_listing
    lat = self.latitude
    lon = self.longitude
    query = "#{lat},#{lon}"
    result = Geocoder.search(query).first

    if result.present?
      self.city = result.city
      self.country = result.country
    end
  end

end
