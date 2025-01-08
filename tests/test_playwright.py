from playwright.sync_api import sync_playwright


def run_playwright_test():
    with sync_playwright() as p:
        print('Launching Chromium...')

        # Launch browser in headless mode
        browser = p.chromium.launch(headless=True)

        # Create a new page
        page = browser.new_page()

        try:
            # Navigate to example.com with a 60-second timeout
            page.goto('https://example.com', timeout=60000)

            # Print page title
            print('Page title:', page.title())

            # Optional: Take a screenshot
            page.screenshot(path='example_screenshot.png')

            # Optional: Print page URL
            print('Current URL:', page.url)

        except Exception as e:
            print(f'An error occurred: {e}')

        finally:
            # Always close the browser
            browser.close()

        print('✅ Playwright test completed successfully!')


# Run the test
if __name__ == '__main__':
    run_playwright_test()