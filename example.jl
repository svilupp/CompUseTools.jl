using ChromeDevToolsLite
using CompUseTools

client = connect_browser()
screenshot(client; save_path = "screenshot.png");