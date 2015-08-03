class ListingsController < ApplicationController

  before_action :set_listing, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :index2, :show]
  before_action :correct_user, only: [:edit, :update, :destroy]


  # GET /listings
  # GET /listings.json
  def index
    @listings = Listing.all
  end

  def index2
    @listings = Listing.all
  end

  def managelistings
    @listings = current_user.listings.order(:name)
  end

  # GET /listings/1
  # GET /listings/1.json
  def show
  end

  # GET /listings/new
  def new

    @listing = current_user.listings.build
  end

  # GET /listings/1/edit
  def edit

  end

  # POST /listings
  # POST /listings.json
  def create
    @listing = current_user.listings.build(listing_params)

    respond_to do |format|
      if @listing.save
        format.html { redirect_to manage_listings_path, notice: 'Listing was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /listings/1
  # PATCH/PUT /listings/1.json
  def update
    respond_to do |format|
      if @listing.update(listing_params)
        format.html { redirect_to manage_listings_path, notice: 'Listing was successfully updated.' }
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
      format.html { redirect_to manage_listings_path, notice: 'Listing was successfully destroyed.' }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_listing
      @listing = Listing.find(params[:id])
    end

    def correct_user
      @listing = current_user.listings.find_by(id: params[:id])
      redirect_to listings_path, notice: "Not authorized to edit this listing" if @listing.nil?
    end

    def maj_user
      # encoding: utf-8
      @user = current_user
      @error_message = "Merci de mettre � jour votre profil"
      if @user.iban.empty?
        redirect_to edit_user_registration_path, notice:  @error_message
      elsif @user.bic.empty?
        redirect_to edit_user_registration_path, notice:  @error_message
      elsif @user.birthday.empty?
        redirect_to edit_user_registration_path, notice:  @error_message
      elsif @user.adressline1.empty?
        redirect_to edit_user_registration_path, notice:  @error_message
      elsif @user.city.empty?
        redirect_to edit_user_registration_path, notice:  @error_message
      elsif @user.country.empty?
        redirect_to edit_user_registration_path, notice:  @error_message
      elsif @user.postalcode.empty?
        redirect_to edit_user_registration_path, notice:  @error_message
      elsif @user.nationality.empty?
        redirect_to edit_user_registration_path, notice:  @error_message
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def listing_params
      params.require(:listing).permit(:name, :summary,:description, :images_attributes => [:id, :_destroy, :photo, :listing_id])
    end
end
