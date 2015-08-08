class Admin::AdminController < ApplicationController

  before_filter :admin


  def home
    @orders = Order.payed.payout
  end




end