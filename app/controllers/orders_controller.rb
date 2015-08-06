class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy]
  before_filter :load_post, only: [:new]
  before_action :authenticate_user!

  # GET /orders
  # GET /orders.json
  def index
    @orders = Order.all
  end

  def sales
    @orders = Order.all.where(seller: current_user).order("created_at DESC")
    @q = Order.ransack(params[:q])
    @orders = @q.result(distinct: true).where(seller: current_user).order("created_at DESC").paginate(:page => params[:page], :per_page => 5)
    respond_to do |format|
      format.html
    end
  end

  def purchases
    @orders = Order.all.where(buyer: current_user).order("created_at DESC")
    @q = Order.ransack(params[:q])
    @orders = @q.result(distinct: true).where(buyer: current_user).order("created_at DESC").paginate(:page => params[:page], :per_page => 5)
    respond_to do |format|
      format.html
    end
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
  end

  # GET /orders/new
  def new
    @order = Order.new
    @listing = Listing.find(params[:listing_id])
  end


  # GET /orders/1/edit
  def edit
    @order = Order.find(params[:id])
    @listing = Listing.find(params[:listing_id])
    @messages =   Message.all.where(order_id: @order).order("created_at DESC")

    @message =   @order.messages.new
  end

  def create
    @order = Order.new(order_params)
    @listing = Listing.find(params[:listing_id])
    @seller = @listing.user

    @order.seller_id = @seller.id
    @order.listing_id = @listing.id
    @order.buyer_id = current_user.id
    @order.status = "Pending"


    respond_to do |format|
      if @order.save
        format.html { redirect_to listing_path(@listing), notice: 'Order was successfully created.' }
      else
        format.html { redirect_to listing_path(@listing), notice: 'Nous avons un probleme technique' }
      end
    end
  end

  def update
    @order = Order.find(params[:id])

    respond_to do |format|
      if params[:validated]
        @order.status = "Validated"
        #autres actions
        @order.save
        format.html { redirect_to sales_path, notice: 'Validated' }
      elsif params[:refused]
        @order.status = "Refused"
        #autres actions
        @order.save
        format.html { redirect_to sales_path, notice: 'Refused' }
      elsif params[:cancelled]
        @order.status = "Cancelled"
        #autres actions
        @order.save
        format.html { redirect_to cancellation_path, notice: 'Cancelled' }
      elsif params[:payed]
        @order.status = "Payed"
        #autres actions
        @order.save
        format.html { redirect_to purchases_path, notice: 'Payed' }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @order.destroy
    respond_to do |format|
      format.html { redirect_to orders_url, notice: 'Order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def load_post
      @listing = Listing.find(params[:listing_id])
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:start_date, :end_date, :order_price, :listing_id,:buyer_id, :seller_id, :status, :message )
    end
end
