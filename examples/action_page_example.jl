using CompUseTools
using ChromeDevToolsLite
using HTTP
using JSON3
using Base64

# Configuration
const PORT = 9222

# Initialize Chrome session with error handling
global client = nothing

try
    # Get available targets
    @info "Getting Chrome targets..."
    targets = HTTP.get("http://localhost:$PORT/json").body |> String |> JSON3.read
    isempty(targets) && error("No Chrome targets found")

    # Create a new target
    @info "Creating new target..."
    new_target = HTTP.put("http://localhost:$PORT/json/new", [], JSON3.write(Dict("url" => "about:blank"))).body |> String |> JSON3.read

    # Initialize Chrome session with the new target
    @info "Connecting to Chrome..."
    global client = WSClient(new_target.webSocketDebuggerUrl)
    connect!(client)

    # Enable domains and set up page
    @info "Setting up page..."
    send_cdp(client, "Page.enable", Dict{String, Any}())
    send_cdp(client, "Runtime.enable", Dict{String, Any}())
    send_cdp(client, "Network.enable", Dict{String, Any}())

    # Set viewport
    send_cdp(client, "Emulation.setDeviceMetricsOverride", Dict(
        "width" => 1280,
        "height" => 800,
        "deviceScaleFactor" => 1,
        "mobile" => false
    ))

    # Navigate to the page
    @info "Navigating to page..."
    nav_result = send_cdp(client, "Page.navigate", Dict("url" => "https://example.com"))
    @info "Navigation result:" nav_result

    # Wait for load event
    @info "Waiting for load..."
    timeout = time() + 15
    load_complete = false

    while time() < timeout && !load_complete
        sleep(0.5)
        try
            ready = send_cdp(client, "Runtime.evaluate", Dict(
                "expression" => "document.readyState",
                "returnByValue" => true
            ))

            if haskey(ready, "result") && haskey(ready["result"], "result") &&
               haskey(ready["result"]["result"], "value") &&
               ready["result"]["result"]["value"] == "complete"
                @info "Page loaded successfully"
                load_complete = true
                sleep(2)
                break
            end
        catch e
            @warn "Error checking page status" exception=e
        end
    end

    if !load_complete
        error("Page failed to load within timeout")
    end

    # Take screenshot
    @info "Taking screenshot..."
    screenshot_path = joinpath(@__DIR__, "action_page_screenshot.png")

    # Try multiple times for screenshot
    for attempt in 1:3
        try
            result = send_cdp(client, "Page.captureScreenshot", Dict{String,Any}(); timeout=5.0)
            open(screenshot_path, "w") do io
                write(io, base64decode(result["result"]["data"]))
            end
            @info "Screenshot captured successfully"
            break
        catch e
            if attempt == 3
                rethrow(e)
            else
                @warn "Screenshot attempt $attempt failed, retrying..." exception=e
                sleep(1)
            end
        end
    end

    # Get page content
    @info "Getting page content..."
    html_content = content(client)

    # Create ActionPage
    @info "Creating ActionPage..."
    action_page = annotate_page(
        "https://example.com",  # Use the actual URL we navigated to
        screenshot_path,
        html_content,
        html_content  # Pass HTML content for accessibility tree
    )

    # Print results
    println("\nResults:")
    println("✓ Created ActionPage for: ", action_page.url)
    println("✓ Number of action items: ", length(action_page.action_items))
    println("✓ Annotated image saved at: ", action_page.image_path)
    println("\nSimplified HTML preview (first 500 chars):")
    println(action_page.html[1:min(500, length(action_page.html))])

catch error
    @error "Failed to process page" exception=(error, catch_backtrace())
finally
    # Clean up
    @info "Cleaning up..."
    if !isnothing(client)
        try
            ChromeDevToolsLite.close(client)
        catch close_error
            @warn "Failed to close client" exception=close_error
        end
    end
end
