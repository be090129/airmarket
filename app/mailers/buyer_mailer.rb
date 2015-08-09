#encoding: utf-8

class BuyerMailer < ActionMailer::Base

  default from: "reservation@exclusive-villas.com"

  def validated_order(order)
    @order = order
    mail(:to => order.buyer.email, :subject => "Votre demande a été acceptée")
  end

  def refused_order(order)
    @order = order
    mail(:to => order.buyer.email, :subject => "Votre demande a été refusée")
  end

  def buyer_payed_order(order)
    @order = order
    mail(:to => order.buyer.email, :subject => "Votre demande est confirmée")
  end

  def buyer_expired_order(order)
    @order = order
    mail(:to => order.buyer.email, :subject => "Votre demande a expirée")
  end


end