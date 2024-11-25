using CompUseTools
using ChromeDevToolsLite

# Start chromium in debugging mode (should already be running on port 9222)
# Launch script: chromium-browser --remote-debugging-port=9222 --headless --disable-gpu --no-sandbox

println("Testing local HTML content:")
println("==========================")

# Create a simple test HTML string
test_html = """
<!DOCTYPE html>
<html>
<body>
    <header role="banner">
        <h1>Test Page</h1>
        <nav role="navigation" aria-label="Main menu">
            <ul>
                <li><a href="#" aria-current="page">Home</a></li>
                <li><a href="#">About</a></li>
            </ul>
        </nav>
    </header>
    <main role="main">
        <form role="search">
            <label for="search">Search:</label>
            <input type="search" id="search" aria-label="Search the site" />
            <button type="submit" aria-label="Submit search">Search</button>
        </form>
    </main>
</body>
</html>
"""

# Parse the content and build accessibility tree
access_tree = html_to_accessibility_tree(test_html)

# Print the accessibility tree
println("Accessibility Tree for Test Page:")
println("=================================")
print_accessibility_tree(access_tree)

println("\nTesting live webpage content:")
println("=============================")

try
    # Extract accessibility tree using our high-level function
    live_tree = extract_accessibility_tree("https://example.com")

    # Print the accessibility tree
    println("Accessibility Tree for example.com:")
    println("===================================")
    print_accessibility_tree(live_tree)
catch e
    println("Error: Make sure Chrome is running with --remote-debugging-port=9222")
    println(e)
end
