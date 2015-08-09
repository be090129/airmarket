class PagesController < ApplicationController
  def home
    @lastest = Listing.all.order("created_at DESC")
    @miseenavant = Listing.miseenavant
  end
  def about
  end

  def cancellation
  end
end
