import { test, expect } from '@playwright/test';

test.describe('Visual Regression', () => {
  test('Homepage matches snapshot', async ({ page }) => {
    // Navigate to homepage
    await page.goto('http://localhost:5173');
    
    // Wait for welcome text to appear
    await expect(page.getByText('Hello, Human')).toBeVisible();
    
    // Take screenshot of the entire page
    await expect(page).toHaveScreenshot('homepage.png', {
      maxDiffPixels: 100, // Tolerance for minor rendering differences
    });
  });

  test('Sidebar matches snapshot', async ({ page }) => {
    await page.goto('http://localhost:5173');
    
    // Take screenshot of sidebar
    const sidebar = page.locator('aside'); // Assuming sidebar is an <aside> or has a specific class
    await expect(sidebar).toHaveScreenshot('sidebar.png');
  });

  test('Chat interaction visual check', async ({ page }) => {
    await page.goto('http://localhost:5173');
    
    // Type a message
    await page.getByPlaceholder('Ask anything...').fill('Hello Gemini');
    
    // Check input area state
    const inputArea = page.locator('.flex-shrink-0.p-4.bg-background');
    await expect(inputArea).toHaveScreenshot('input-area-active.png');
  });
});
