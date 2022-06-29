class Car < ApplocationRecord 
    def payment_method
        payment_method = PaymentMethod.find_by(code: "PEC")
        Payment.create(
            order_id: order.id,
            payment_method_id: payment_method.id,
            state: "processing",
            total: order.total,
            token: response.token
        )
    end

    def process_paypal_payment
        response = EXPRESS_GATEWAY.purchase(price, express_purchase_options)
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
end