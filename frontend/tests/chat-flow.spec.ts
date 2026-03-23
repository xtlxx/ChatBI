
import { test, expect } from '@playwright/test';

test.describe('Chat Flow', () => {
  test('should handle complete chat flow with streaming events', async ({ page }) => {
    // Enable console logs
     page.on('console', msg => console.log('BROWSER LOG:', msg.text()));
 
     // Mock session list to prevent 401
      await page.route('**/api/chat/sessions*', async route => {
          console.log('Mocking sessions request: ' + route.request().url());
          await route.fulfill({
              status: 200,
              contentType: 'application/json',
              body: JSON.stringify([])
          });
      });
  
      // Mock the streaming API
      await page.route('**/*query/stream*', async route => {
        console.log('Mocking stream request');
        
        const events = [
          { type: 'start', content: 'Start processing' },
          { type: 'thinking', content: 'Thinking step 1...' },
          { type: 'thinking', content: 'Thinking step 2...' },
          { type: 'sql_generated', content: 'SELECT * FROM users', thought: 'Query users', metadata: { execution_time: 0.1 } },
          { type: 'execution_result', content: 'Query successful, 2 rows returned' },
          { type: 'final_answer', content: 'Here are the users: User 1, User 2', thinking: 'Thinking step 1...Thinking step 2...', sql: 'SELECT * FROM users' },
          { type: 'end', content: '' }
        ];

        const streamBody = events.map(e => `data: ${JSON.stringify(e)}\n\n`).join('');

        await route.fulfill({
          status: 200,
          contentType: 'text/event-stream',
          body: streamBody
        });
      });

    // Set localStorage for auth and settings
    await page.addInitScript(() => {
        window.localStorage.setItem('auth-storage', JSON.stringify({
            state: {
                user: { id: 1, username: 'testuser' },
                token: 'fake-token',
                isAuthenticated: true
            },
            version: 0
        }));
        window.localStorage.setItem('chat-settings-storage', JSON.stringify({
            state: {
                selectedConnectionId: 1,
                selectedLlmConfigId: 1
            },
            version: 0
        }));
    });

    // Navigate to new chat
    await page.goto('http://localhost:5174/chat/new');

    // Wait for page load
    await expect(page.getByText('Gemini')).toBeVisible();

    // Type message
    await page.fill('textarea', 'Show me users');

    // Click send
    await page.click('button[aria-label="Send message"]');

    // Verify Thinking
    // First wait for Thoughts trigger to appear (indicating thinking started)
    try {
        await expect(page.getByText('Thoughts')).toBeVisible({ timeout: 5000 });
    } catch (e) {
        console.log('Thoughts not found, checking for chat.thoughts');
        try {
            await expect(page.getByText('chat.thoughts')).toBeVisible({ timeout: 1000 });
            console.log('Found chat.thoughts key instead of translation');
        } catch (e2) {
            console.log('Neither found. Dumping body:', e2);
            console.log(await page.locator('body').innerHTML());
            throw e;
        }
    }
    
    // Click to expand thinking
    await page.getByText('Thoughts').click();
    
    // Verify Final Answer first (ensures stream is complete)
    await expect(page.getByText('Here are the users: User 1, User 2')).toBeVisible();

    // Verify Thinking Process (expandable)
    // Click only if not already visible (it might stay open)
    const thinkingTrigger = page.locator('button', { hasText: 'Thoughts' });
    if (await thinkingTrigger.isVisible()) {
       // Check if content is visible
       if (!(await page.getByText('Thinking step 1...').isVisible())) {
          await thinkingTrigger.click();
       }
    }
    await expect(page.getByText('Thinking step 1...')).toBeVisible();
    await expect(page.getByText('Thinking step 2...')).toBeVisible();
    
    // Verify SQL Thought
    await expect(page.getByText('Query users')).toBeVisible();
    
    // Verify SQL Block
    await expect(page.getByText('SELECT * FROM users')).toBeVisible();

    // Verify SQL Code
    await expect(page.getByText('SELECT * FROM users')).toBeVisible();
  });
});
