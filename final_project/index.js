const express = require('express');
const jwt = require('jsonwebtoken');
const session = require('express-session')
const customer_routes = require('./router/auth_users.js').authenticated;
const genl_routes = require('./router/general.js').general;

const app = express();

app.use(express.json());

app.use("/customer",session({secret:"fingerprint_customer",resave: true, saveUninitialized: true}))

app.use("/customer/auth/*", function auth(req,res,next){
  // Accept the token from the session (set at login) or from an
  // "Authorization: Bearer <token>" header (handy for cURL testing).
  let token = null;
  if (req.session && req.session.authorization) {
    token = req.session.authorization.accessToken;
  } else if (req.headers.authorization && req.headers.authorization.startsWith("Bearer ")) {
    token = req.headers.authorization.split(" ")[1];
  }

  if (!token) {
    return res.status(403).json({ message: "User not logged in" });
  }

  jwt.verify(token, "access", (err, user) => {
    if (err) {
      return res.status(403).json({ message: "User not authenticated" });
    }
    req.user = user;
    next();
  });
});
 
const PORT =5000;

app.use("/customer", customer_routes);
app.use("/", genl_routes);

app.listen(PORT,()=>console.log("Server is running"));
