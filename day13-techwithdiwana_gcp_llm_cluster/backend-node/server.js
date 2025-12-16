
const express = require("express");
const cors = require("cors");
const axios = require("axios");

const app = express();
app.use(cors());
app.use(express.json());

const FASTAPI_URL = process.env.FASTAPI_URL || "http://techwithdiwana-fastapi:8000";

app.get("/healthz", (req, res) => {
  res.json({ status: "ok", service: "techwithdiwana-node-gateway" });
});

app.post("/api/chat", async (req, res) => {
  try {
    const message = (req.body && req.body.message) || "";
    const response = await axios.post(FASTAPI_URL + "/chat", { message });
    res.json(response.data);
  } catch (err) {
    console.error("Error talking to FastAPI backend", err.message);
    res.status(500).json({
      error: "Backend unavailable",
      details: err.message,
    });
  }
});

const port = process.env.PORT || 8080;
app.listen(port, () => {
  console.log(`TechWithDiwana Node gateway listening on port ${port}`);
});
