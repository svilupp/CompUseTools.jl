using CompUseTools
using ChromeDevToolsLite
using HTTP
using JSON3
using Logging

# Set logging level to Info to suppress debug messages
LogLevel(Logging.Info)

# Start Chrome with debugging port
const PORT = 9222
const URL = "https://www.google.com"

# Initialize Chrome session with proper error handling
function run_test()
    browser = nothing
    try
        # Get accessibility tree first
        axtree_node = CompUseTools.extract_accessibility_tree(URL; port=PORT)
        axtree_str = CompUseTools.serialize_accessibility_tree(axtree_node)

        # Then initialize Chrome session for other operations
        browser = ChromeDevToolsLite.connect_browser("ws://localhost:$PORT")
        ChromeDevToolsLite.goto(browser, URL)
        sleep(2)  # Wait for page to load

        # Get page content
        html_content = ChromeDevToolsLite.content(browser)

        # Take a screenshot
        screenshot_path = "test_screenshot.png"
        ChromeDevToolsLite.screenshot(browser; save_path=screenshot_path)

        # Create ActionPage with annotations
        action_page = CompUseTools.annotate_page(
            URL,
            screenshot_path,
            html_content,
            axtree_str
        )

        # Print results
        println("Created ActionPage for: ", action_page.url)
        println("Number of action items: ", length(action_page.action_items))
        println("Annotated image saved at: ", action_page.image_path)
        println("\nFirst 200 characters of simplified HTML:")
        println(first(action_page.html, 200))

    catch e
        println("Error: ", e)
        rethrow(e)
    finally
        if !isnothing(browser)
            close(browser)
        end
    end
end

run_test()
