require("dotenv").config();
const express = require("express");
const app = express();
const morgan = require("morgan");
const cors = require("cors");
const path = require("path");

app.disable("x-powered-by");
app.use(morgan("dev"));
app.use(cors());

app.use(express.json());
app.use(express.urlencoded({ extended: false }))

app.listen(9000, (err) => {
    console.log( err ? err : 'Listening' );
})

require('./router')(app)
