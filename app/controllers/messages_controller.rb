class MessagesController < ApplicationController
  before_action :set_message, only: [:show, :edit, :update, :destroy]
  before_filter :load_post, only: [:create]
  before_action :authenticate_user!

  def new
    @message = Message.new
  end

  def create
    @message = Message.new(message_params)
    @listing =  Listing.find(params[:listing_id])
    @order = Order.find(params[:order_id])
    @message.user_id = current_user.id
    @message.order_id = @order.id

    respond_to do |format|
      if @message.save
        format.html { redirect_to edit_listing_order_path(@order.listing_id, @order.id ), notice: 'Message was successfully created.' }
      else
        format.html { redirect_to edit_listing_order_path(@order.listing_id, @order.id ), notice: 'Merci de saisir votre message' }
      end
    end
  end

  private
    def load_post
      @order = Order.find(params[:order_id])
      @listing = Listing.find(params[:listing_id])
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = Message.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def message_params
      params.require(:message).permit(:message, :order_id, :user_id)
    end
end
