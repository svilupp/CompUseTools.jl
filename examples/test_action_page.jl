using CompUseTools
using Images
using ImageDraw
using ImageCore
using ImageDraw: Point

# Create some test ActionItems
action_items = [
    ActionItem(x1=100, y1=100, x2=150, y2=150, label="button1", id=1),
    ActionItem(x1=200, y1=200, x2=250, y2=250, label="input", id=2),
    ActionItem(x1=300, y1=300, x2=350, y2=350, label="link", id=3)
]

# Create a test image
img = fill(RGB{N0f8}(1,1,1), 500, 500)
save("test_base.png", img)

# Create an ActionPage
page = ActionPage(
    url="https://example.com",
    image_path="test_base.png",
    html="<html><body>Test page</body></html>",
    axtree="Simple accessibility tree",
    action_items=action_items
)

# Test drawing annotations
img_annotated = fill(RGB{N0f8}(1,1,1), 500, 500)
for item in page.action_items
    color = RGB{N0f8}(rand(), rand(), rand())
    draw!(img_annotated, Polygon(RectanglePoints(Point(item.x1, item.y1), Point(item.x2, item.y2))), color)
    CompUseTools.draw_number!(img_annotated, item.id, round(Int, item.x1), round(Int, item.y1-20), 30, color)
end
save("test_action_page.png", img_annotated)

println("ActionPage test completed!")
println("Number of action items: ", length(page.action_items))
println("Check test_action_page.png for visual results")
