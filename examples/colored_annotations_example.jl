using CompUseTools
using ChromeDevToolsLite
using HTTP
using JSON3

# Start Chrome with debugging port
const PORT = 9222
const URL = "https://www.google.com"

# Function to wait for browser and get debug info
function wait_for_browser(port, max_retries=5)
    for i in 1:max_retries
        try
            sleep(2)  # Increased wait time
            response = HTTP.get("http://localhost:$port/json/version")
            if response.status == 200
                return String(response.body)
            end
        catch e
            @warn "Attempt $i failed: $(e)"
            if i == max_retries
                error("Failed to connect to browser after $max_retries attempts")
            end
        end
    end
end

# Wait for browser to be ready
@info "Starting browser session..."
browser_info = wait_for_browser(PORT)
browser_data = JSON3.read(browser_info)

# Create a new target
@info "Creating new target..."
new_target_response = HTTP.put("http://localhost:$PORT/json/new")
target_data = JSON3.read(String(new_target_response.body))

# Create WebSocket client
@info "Creating WebSocket client..." target_data.webSocketDebuggerUrl
client = ChromeDevToolsLite.WSClient(target_data.webSocketDebuggerUrl)
sleep(2)  # Give WebSocket time to establish

# Create the Page session
@info "Creating Page session..."
extras = Dict{String,Any}()
session = ChromeDevToolsLite.Page(;
    client=client,
    target_id=target_data.id,
    extras=extras
)

try
    @info "Navigating to $URL"
    ChromeDevToolsLite.navigate!(session, URL)
    sleep(3)  # Wait for navigation

    # Get page content
    html_content = ChromeDevToolsLite.content(session)

    # Get accessibility tree
    axtree = CompUseTools.extract_accessibility_tree(session)

    # Take a screenshot
    screenshot_path = "colored_annotations_screenshot.png"
    ChromeDevToolsLite.screenshot!(session, screenshot_path)

    # Create ActionPage with colored annotations
    page = CompUseTools.annotate_page(
        URL,
        screenshot_path,
        html_content,
        axtree
    )

    # Print results
    println("Created ActionPage for: ", page.url)
    println("Number of action items: ", length(page.action_items))
    println("Annotated image saved at: ", page.image_path)

finally
    # Clean up
    ChromeDevToolsLite.close(session)
end
