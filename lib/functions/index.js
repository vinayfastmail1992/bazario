const functions = require("firebase-functions");
const Razorpay = require("razorpay");
const cors = require("cors")({ origin: true });

const instance = new Razorpay({
    key_id: "rzp_test_6fRiuUhQ6ksrm8",
    key_secret: "TjERiZczrsB6nyR1DtfHRQBs",
});

exports.createOrder = functions.https.onRequest((req, res) => {
    cors(req, res, () => {
        if (req.method !== "POST") {
            return res.status(405).send("Method Not Allowed");
        }

        const options = {
            amount: req.body.amount, // amount in paise
            currency: "INR",
            receipt: "receipt_order_" + Date.now(),
        };

        instance.orders.create(options, (err, order) => {
            if (err) {
                console.error("Razorpay Error:", err);
                return res.status(500).send({ error: err.message });
            }
            res.status(200).send(order);
        });
    });
});
