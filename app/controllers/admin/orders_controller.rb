class Admin::OrdersController < Admin::AdminController
  before_action :set_order, only: [:show, :edit, :update, :destroy]


  # GET /orders
  # GET /orders.json
  def index
    @orders = Order.all.order("created_at DESC").paginate(:page => params[:page], :per_page => 20)
    @q = Order.ransack(params[:q])
    @orders = @q.result(distinct: true).order("created_at DESC").paginate(:page => params[:page], :per_page => 20)
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

  end


  # GET /orders/1/edit
  def edit
    @messages =   Message.all.where(order_id: @order).order("created_at DESC")
  end

  def create
    @order = Order.new(order_params)

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
      if params[:expired]
        @order.status = "Expired"
        BuyerMailer.buyer_expired_order(@order).deliver_now
        SellerMailer.seller_expired_order(@order).deliver_now
        #autres actions
        @order.save
        format.html { redirect_to admin_root_path, notice: 'Expired' }
      end
    end

  end

  def destroy
    @order.destroy
    respond_to do |format|
      format.html { redirect_to admin_orders_url, notice: 'Order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end



  private

    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:start_date, :end_date, :order_price, :listing_id,:buyer_id, :seller_id, :status, :message, :check_payin, :check_payout, :fees_buyer, :validated_time, :fees_seller, :order_payout, :mangopay_transaction_id,:mangopay_payout_id )
    end
end
