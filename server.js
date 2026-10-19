require("dotenv").config();

const express = require("express");
const helmet = require("helmet");
const { Pool } = require("pg");
const path = require("path");

const app = express();
const PORT = process.env.PORT || 3000;

app.use(helmet({
  contentSecurityPolicy: false
}));

app.use(express.json({ limit: "100kb" }));
app.use(express.urlencoded({ extended: false }));

// PostgreSQL database connection
const pool = process.env.DATABASE_URL
  ? new Pool({
      connectionString: process.env.DATABASE_URL,
      ssl: process.env.NODE_ENV === "production"
        ? { rejectUnauthorized: false }
        : undefined
    })
  : null;

// Health check
app.get("/api/health", (req, res) => {
  res.json({
    success: true,
    name: "MR S4M WEB STORE",
    status: "running"
  });
});

// Database status
app.get("/api/database-status", async (req, res) => {
  if (!pool) {
    return res.status(503).json({
      success: false,
      message: "Database is not configured yet"
    });
  }

  try {
    await pool.query("SELECT 1");
    res.json({
      success: true,
      message: "Database connected"
    });
  } catch (error) {
    console.error("Database connection failed");
    res.status(503).json({
      success: false,
      message: "Database connection failed"
    });
  }
});

// Serve website files
app.use(express.static(path.join(__dirname, "public")));

// Root page
app.get("/", (req, res) => {
  res.sendFile(path.join(__dirname, "index.html"));
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: "Route not found"
  });
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`MR S4M WEB STORE running on port ${PORT}`);
});
