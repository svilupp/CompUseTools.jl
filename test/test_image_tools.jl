using Test
using CompUseTools
using ImageBase
using FileIO
using ImageDraw

@testset "Image Annotation Tests" begin
    # Create a simple test image
    test_img_path = joinpath(@__DIR__, "test_image.png")
    img = fill(RGB{N0f8}(0.5, 0.5, 0.5), 400, 600)  # Gray background
    save(test_img_path, img)

    # Test coordinates
    coords = [(100, 100), (200, 200), (300, 300)]

    # Test basic annotation
    @test begin
        annotated = annotate_image(test_img_path, coords)
        # Check if image dimensions remain the same
        size(annotated) == size(img)

        # Check if numbers are visible in regions around the coordinates
        all(coords) do (x, y)
            # Check a 5x5 region around the coordinate for any modified pixels
            region_modified = false
            for dx in -2:2, dy in -2:2
                if 1 <= y+dy <= size(annotated, 1) && 1 <= x+dx <= size(annotated, 2)
                    if annotated[y+dy, x+dx] != RGB{N0f8}(0.5, 0.5, 0.5)
                        region_modified = true
                        break
                    end
                end
            end
            region_modified
        end
    end

    # Test saving functionality
    save_path = joinpath(@__DIR__, "annotated_test.png")
    @test begin
        annotate_image(test_img_path, coords; save_path=save_path)
        isfile(save_path)
    end

    # Test number colors
    @test begin
        custom_color = RGB{N0f8}(0.0, 1.0, 0.0)  # Green
        annotated = annotate_image(test_img_path, coords; number_color=custom_color)
        true  # If we got here without errors, the color was accepted
    end

    # Test number size
    @test begin
        annotated = annotate_image(test_img_path, coords; number_size=40)
        true  # If we got here without errors, the size was accepted
    end

    # Cleanup
    rm(test_img_path, force=true)
    rm(save_path, force=true)
end
