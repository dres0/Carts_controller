class CartsController < ApplicationController
    before_action :authenticate_user!
    
    def update
        product = params[:cart][:product_id]
        quantity = params[:cart][:quantity]
    
        current_order.add_product(product, quantity)
    
        redirect_to root_url, notice: "Product added successfuly"
    end
    
    def show
        @order = current_order
    end
    
    def pay_with_paypal
        order = Order.find(params[:cart][:order_id])
    
        #price must be in cents
        price = order.total * 100
    
        redirect_to EXPRESS_GATEWAY.redirect_url_for(response.token)
    end
    
    def process_paypal_payment
        details = EXPRESS_GATEWAY.details_for(params[:token])
        
        price = details.params["order_total"].to_d * 100
        
        response = EXPRESS_GATEWAY.purchase(price, express_purchase_options)
    end
end        