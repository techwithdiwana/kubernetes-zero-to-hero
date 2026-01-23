const { test, expect } = require("@playwright/test");

test("ui smoke test open page", async ({ page }) => {
  await page.goto("/");
  await expect(page).toHaveTitle(/Example Domain/);
});

test("ui smoke test check heading", async ({ page }) => {
  await page.goto("/");
  await expect(page.locator("h1")).toHaveText("Example Domain");
});
