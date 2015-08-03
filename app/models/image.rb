class Image < ActiveRecord::Base
  belongs_to :listing
  belongs_to :user

  has_attached_file :photo, :styles => { :medium => "1024x683>", :thumb => "225x150>", :avatar => "100x100#" }, :default_url => "/images/:style/missing.jpg"
  validates_attachment_content_type :photo, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]
end
