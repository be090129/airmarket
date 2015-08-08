class AirmarketApi
  class << self

    def calculate_order(listing, order)
      fees_b = 0.03
      fees_s = 0.1

      period = (order.end_date - order.start_date)
      price = listing.listing_price_standard * period

      order.fees_buyer = (fees_b * price).round(0)
      order.fees_seller = (fees_s * price).round(0)

      order.order_price = price +  order.fees_seller
      order.order_payout = price -  order.fees_buyer

    end

  end
end