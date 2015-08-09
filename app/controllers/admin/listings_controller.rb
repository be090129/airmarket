class Admin::ListingsController < Admin::AdminController

  before_action :set_listing, only: [:show, :edit, :update, :destroy]




  # GET /listings
  # GET /listings.json
  def index
    @listings = Listing.all.order("created_at DESC").paginate(:page => params[:page], :per_page => 20)
    @q = Listing.ransack(params[:q])
    @listings = @q.result(distinct: true).order("created_at DESC").paginate(:page => params[:page], :per_page => 20)
    respond_to do |format|
      format.html
    end
  end


  # GET /listings/1/edit
  def edit

  end

  # PATCH/PUT /listings/1
  # PATCH/PUT /listings/1.json
  def update
    @listing = Listing.find(params[:id])

    respond_to do |format|
      if @listing.update(listing_params)
        format.html { redirect_to admin_listings_path, notice: 'Listing was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /listings/1
  # DELETE /listings/1.json
  def destroy
    @listing.destroy
    respond_to do |format|
      format.html { redirect_to admin_listings_path, notice: 'Listing was successfully destroyed.' }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_listing
      @listing = Listing.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def listing_params
      params.require(:listing).permit(:name, :summary,:description,:listing_price_standard, :address,:city, :country, :latitude, :longitude,:miseenavant,  :images_attributes => [:id, :_destroy, :photo, :listing_id])
    end
end
