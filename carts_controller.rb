class CartsController < ApplicationController
    before_action :authenticate_user!
    before_action :cart, only: [:show, :update]


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
        @order = Order.find(params[:cart][:order_id])
        #price must be in cents
        price = order.total * 100
        response = EXPRESS_GATEWAY.setup_purchase(price,
            ip: request.remote_ip,
            return_url: process_paypal_payment_cart_url,
            cancel_return_url: root_url,
            allow_guest_checkout: true,
            currency: "USD"
        )
        render json: { pay_with_paypal: @order.payment_method}
        redirect_to EXPRESS_GATEWAY.redirect_url_for(response.token)
    end
    
    def process_paypal_payment
        @order = Order.find(params[:cart][:order_id])
        details = EXPRESS_GATEWAY.details_for(params[:token])
        express_purchase_options =
        {
            ip: request.remote_ip,
            token: params[:token],
            payer_id: details.payer_id,
            currency: "USD"
        }
        price = details.params["order_total"].to_d * 100
        render json: { process_paypal_payment: @order.process_paypal_payment}
    end
end        