class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy]
  before_filter :load_post, only: [:new]

  before_action :authenticate_user!, except: [:valid_payin]
  before_action :maj_user, only: [:new, :create]

  before_action :createMangopayCardRegister, only: [:payin]
  before_action :get_card_id, only: [:payin]
  before_action :calcul_payoutproprietaire, only: [:payoutproprietaire]


  def createMangopayCardRegister

    @cardPreRegistration=nil
    buyer=Order.find(params[:id]).buyer

    reset_session if !session.has_key?(:firstloadok)

    if !session.has_key?(:firstloadok)
      return_value=MangopayApi.create_cb_registration(buyer.mangopay_user_id)
      mangopay_api_throws_an_error(return_value) ? (error= return_value) : (@cardPreRegistration=return_value)
      if !error.nil?
        flash[:error] = error
      else
        session[:cardPreRegistration]=@cardPreRegistration
        session[:firstloadok]=true
        #get_card_id
      end
    end
  end


  def payin
    #back from 3dSecure
    valid_payin(params[:transactionId]) if params[:transactionId]

    @order=Order.find(params[:id])

    if !(@order.buyer.mangopay_card_id.nil? || @order.buyer.mangopay_card_id==0)
      mangopay_api_call_result_fetchcardalias = MangopayApi.fetch_card_alias(@order.buyer.mangopay_card_id)
      if mangopay_api_call_result_fetchcardalias.instance_of? MangoPay::ResponseError
        error_string = "Your card details could not be saved, because of following errors: "+ mangopay_api_call_result_fetchcardalias.type+"("+mangopay_api_call_result_fetchcardalias.code+")"+": "+mangopay_api_call_result_fetchcardalias.message
        flash[:error] = error_string
      else
        @card_alias=mangopay_api_call_result_fetchcardalias["Alias"]
      end
    else
      @cardPreRegistration = session[:cardPreRegistration]
      #@cardPreRegistration = MangopayApi.fetch_cb_registration(@cardPreRegistration)
    end
  end


  def payin_ok
    @order=Order.find(params[:id])
  end

  def get_card_id
    if params[:data] || params[:errorCode]
      @order=Order.find(params[:id])
      @cardPreRegistration=session[:cardPreRegistration]

      if (@order.buyer.mangopay_card_id.nil? || @order.buyer.mangopay_card_id==0)
        #@cardPreRegistration = session[:cardPreRegistration]
        if params[:data]
          @cardPreRegistration["RegistrationData"]="data="+params[:data]
        elsif params[:errorCode]
          case params[:errorCode]
            when "02625"
              error_info= "Numero de carte invalide"
            when "02626"
              error_info= "Date d'expiration invalide. Utilisez le format mmdd (ex: 0715)"
            when "02627"
              error_info= "Cryptogramme (CCV) invalide"
            when "02628"
              error_info= "Transaction refusee"
          end
          error_alert = "Vos informations de paiement sont erronees"
          error_solution="Verifiez vos informations de paiement"
          flash[:error] = MangopayApi.process_error("Card registration",error_alert,error_info,error_solution,{:current_user => @order.buyer.email, :mangopay_details => params[:errorCode]})
          return redirect_to :payin
        end

        if not @cardPreRegistration["RegistrationData"].blank?
          mangopay_api_call_result_getcardid = MangopayApi.update_cb_registration(@cardPreRegistration)
        end

        if mangopay_api_call_result_getcardid.instance_of? MangoPay::ResponseError
          flash[:error] = MangopayApi.process_error("Card registration","Paiement impossible",mangopay_api_call_result_getcardid.message,nil,{:current_user => "air market", :mangopay_details => mangopay_api_call_result_getcardid.code})
          return redirect_to :payin
        else
          #Save cardId
          @order.buyer.mangopay_card_id=mangopay_api_call_result_getcardid["CardId"]
          @order.buyer.save
        end
      end

      dopayin if !(@order.buyer.mangopay_card_id.nil? || @order.buyer.mangopay_card_id==0)
    end
  end

  def dopayin
    #PAYIN
    @order = Order.find(params[:id])
    @price = @order.order_price

    @fees = @order.fees_buyer + @order.fees_seller

    debit_amount_cents =  @price.to_f*100
    fees_amount_cents = @fees.to_f*100

    debit_currency = "EUR"
    secureModeReturnURL= payin_url(@order.id)

    mangopay_api_call_result_dopayin = MangopayApi.create_payin(@order.buyer,debit_amount_cents,debit_currency,fees_amount_cents,secureModeReturnURL)

    if MangopayApi.isInError(mangopay_api_call_result_dopayin)
      show_payin_error(mangopay_api_call_result_dopayin)
    elsif MangopayApi.isIn3dSecure(mangopay_api_call_result_dopayin)
       return redirect_to mangopay_api_call_result_dopayin["SecureModeRedirectURL"]
    else
      transaction_id = mangopay_api_call_result_dopayin["Id"]
      valid_payin(transaction_id)
    end
  end

  #Dernière étape du paiement Mangopay
  def valid_payin(transaction_id)
    mangopay_api_call_result_fetchpayin=MangopayApi.fetch_payin(transaction_id)
    if MangopayApi.isInError(mangopay_api_call_result_fetchpayin)
      show_payin_error(mangopay_api_call_result_fetchpayin)
    elsif (mangopay_api_call_result_fetchpayin["Status"]=="SUCCEEDED")
      @order=Order.find(params[:id])
      @order.mangopay_transaction_id = transaction_id
      @order.check_payin = true
      @order.check_payout = false
      @order.status = "Payed"
      @order.save

      flash[:notice] = "Votre paiement a bien ete enregistre."
      return redirect_to edit_listing_order_path(@order.listing_id, @order.id)
    end
  end



  def show_payin_error(mangopay_api_call)
    error_alert = "Le paiement n'a pas pu etre realise"
    error_info=mangopay_api_call["ResultMessage"]
    error_solution="Contactez votre banque ou nos services pour trouver une autre solution de paiement"
    flash[:error] = MangopayApi.process_error("PayIn",error_alert,error_info,error_solution,{:current_user => "toto", :mangopay_details => mangopay_api_call["ResultCode"]})
    return redirect_to :payin
  end

  def changecard
    buyer=Order.find(params[:id]).buyer
    buyer.mangopay_card_id=nil
    buyer.save
    reset_session
    return redirect_to :payin
  end

  def payoutseller
    @order=Order.find(params[:id])
  end

  def calcul_payoutseller
    @order=Order.find(params[:id])

    mangopayid_proprio= @order.seller.mangopay_user_id
    walletid_proprio= @order.seller.mangopay_wallet_id
    bankid_proprio= @order.seller.mangopay_bank_id

    if (mangopayid_proprio.blank? || walletid_proprio.blank? || bankid_proprio.blank?)
      flash[:error]= "Le payout ne peut etre effectue car les informations bancaires du proprietaire ne sont pas connues"
    end

    @somme_a_payer = @order.order_payout
  end

  def dopayout
    @order=Order.find(params[:id])
    #Transfert de l'argent de la wallet du locataire à la wallet du proprio
    mangopayid_locataire= @order.buyer.mangopay_user_id
    walletid_locataire= @order.buyer.mangopay_wallet_id

    mangopayid_proprio= @order.seller.mangopay_user_id
    walletid_proprio= @order.seller.mangopay_wallet_id
    bankid_proprio= @order.seller.mangopay_bank_id

    @somme_a_payer = @order.order_payout

    fees=0
    montant_payout=@somme_a_payer*100

    mangopay_api_call_result_dotransferbetweenwallet = MangopayApi.transfer_between_wallets(walletid_locataire,walletid_proprio,mangopayid_locataire,mangopayid_proprio,montant_payout,fees)
    if MangopayApi.isInError(mangopay_api_call_result_dotransferbetweenwallet)
      flash[:error] = "Une erreur s est produite lors du transfert entre voyageur et proprio"
    else
      #Virement sur le compte du proprio
      tag= "#{@order.id} / #{@order.buyer.last_name} / #{@order.seller.last_name}"
      mangopay_api_call_result_payout = MangopayApi.payout(walletid_proprio,mangopayid_proprio,bankid_proprio,montant_payout,fees,tag[0...255])
      if MangopayApi.isInError(mangopay_api_call_result_payout)
        flash[:error] = "Une erreur s est produite lors virement sur le compte du proprio"
      else

        @order.mangopay_payout_id=mangopay_api_call_result_payout["Id"]
        @order.check_payout=true

          #envoie email acompte proprietaire

        @order.save
        flash[:notice] = "Demande de virement effectuee avec succes. Le virement sera effectif dans maximum 2 jours."
        return redirect_to admin_root_path
      end
    end
    return redirect_to payoutseller_path(:id => @order.id)
  end

  def mangopay_api_throws_an_error(returned_value)
    returned_value.instance_of? MangoPay::ResponseError
  end


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

  def calculate(listing, order)
    fees_b = 0.03
    fees_s = 0.1
    period = (order.end_date - order.start_date)
    price = listing.listing_price_standard * period
    order.fees_buyer = (fees_b * price).round(0)
    order.fees_seller = (fees_s * price).round(0)
    order.order_price = price +  order.fees_seller
    order.order_payout = price -  order.fees_buyer
  end


  def create
    @order = Order.new(order_params)
    @listing = Listing.find(params[:listing_id])
    @seller = @listing.user

    @order.seller_id = @seller.id
    @order.listing_id = @listing.id
    @order.buyer_id = current_user.id
    @order.status = "Pending"

    calculate(@listing, @order)

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
      format.html { redirect_to admin_orders_url, notice: 'Order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def load_post
      @listing = Listing.find(params[:listing_id])
    end

    def maj_user
      @user = current_user
      @error_message = "Merci de mettre a jour votre profil et de remplir tous les champs vides."
      if @user.birthday.nil?
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

    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:start_date, :end_date, :order_price, :listing_id,:buyer_id, :seller_id, :status, :message,:check_payin,:check_payout, :fees_buyer, :fees_seller, :order_payout, :mangopay_transaction_id,:mangopay_payout_id )
    end
end
