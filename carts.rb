def to_controller1
    response = EXPRESS_GATEWAY.setup_purchase(price,
    ip: request.remote_ip,
    return_url: process_paypal_payment_cart_url,
    cancel_return_url: root_url,
    allow_guest_checkout: true,
    currency: "USD"
    )

    payment_method = PaymentMethod.find_by(code: "PEC")
    Payment.create(
        order_id: order.id,
        payment_method_id: payment_method.id,
        state: "processing",
        total: order.total,
        token: response.token
    )
end

def to_controller2
    if response.success?
        payment = Payment.find_by(token: response.token)
        order = payment.order

        #update object states   
        payment.state = "completed"
        order.state = "completed"

        ActiveRecord::Base.transaction do
            order.save!
            payment.save!
        end
    end
end

def to_controller3
    express_purchase_options =
    {
        ip: request.remote_ip,
        token: params[:token],
        payer_id: details.payer_id,
        currency: "USD"
    }
end