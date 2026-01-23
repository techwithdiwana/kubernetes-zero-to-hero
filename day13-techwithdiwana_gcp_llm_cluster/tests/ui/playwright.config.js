module.exports = {
  testDir: "./",
  timeout: 30 * 1000,
  retries: 1,
  workers: 1,
  use: {
    headless: true,
    baseURL: process.env.UI_BASE_URL || "https://example.com"
  }
};
