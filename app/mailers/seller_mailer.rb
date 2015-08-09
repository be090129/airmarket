#encoding: utf-8

class SellerMailer < ActionMailer::Base

  default from: "reservation@exclusive-villas.com"

  def new_order(order)
    @order = order
    mail(:to => order.seller.email, :subject => "Vous avez une nouvelle demande")
  end


  def seller_payed_order(order)
    @order = order
    mail(:to => order.seller.email, :subject => "Une demande vient d'être confirmée")
  end

  def seller_expired_order(order)
    @order = order
    mail(:to => order.seller.email, :subject => "Une demande vient d'expirer")
  end


end