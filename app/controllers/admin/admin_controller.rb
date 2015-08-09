class Admin::AdminController < ApplicationController

  before_filter :admin


  def home
    @orders = Order.payed.payout
    @pending = Order.expired_pending
    @validated = Order.expired_validated
  end




end