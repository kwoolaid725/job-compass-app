import pytest
from playwright.sync_api import sync_playwright


def test_example_website():
    """
    Pytest-compatible Playwright test for example.com
    """
    with sync_playwright() as p:
        # Launch browser in headless mode
        browser = p.chromium.launch(headless=True)

        try:
            # Create a new page
            page = browser.new_page()

            # Navigate to example.com with a 60-second timeout
            page.goto('https://example.com', timeout=60000)

            # Assertions using pytest
            assert 'Example Domain' in page.title(), "Page title does not match expected"

            # Take a screenshot (optional)
            page.screenshot(path='example_screenshot.png')

            # Additional assertions
            assert page.url == 'https://example.com/', "URL does not match expected"

        except Exception as e:
            pytest.fail(f'Test failed: {e}')

        finally:
            # Always close the browser
            browser.close()