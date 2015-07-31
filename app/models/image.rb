class Image < ActiveRecord::Base
  belongs_to :listing

  has_attached_file :photo, :styles => { :medium => "1024x683>", :thumb => "225x150>" }
  validates_attachment_content_type :photo, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]
end
