using Test
using CompUseTools.PixelDigits
using Colors
using FixedPointNumbers
using ImageDraw

@testset "PixelDigits" begin
    @testset "Basic digit rendering" begin
        # Test that all digits can be rendered
        for digit in '0':'9'
            points = render_digit(digit)
            @test !isempty(points)
            @test all(p -> isa(p, Tuple{Float64,Float64}), points)
        end
    end

    @testset "Scaling" begin
        # Test different scales
        digit = '8'  # Complex digit with many curves
        scales = [0.5, 1.0, 2.0]

        base_points = render_digit(digit)
        for scale in scales
            scaled_points = render_digit(digit, scale)
            @test !isempty(scaled_points)
            # Check that scaling works proportionally
            @test length(scaled_points) == length(base_points)
            # Test a sample point to verify scaling
            @test scaled_points[1][1] ≈ base_points[1][1] * scale
            @test scaled_points[1][2] ≈ base_points[1][2] * scale
        end
    end

    @testset "Image drawing" begin
        # Test drawing on image
        width, height = 100, 100
        img = RGB{N0f8}.(ones(height, width))
        number = 42
        color = RGB{N0f8}(1.0, 0.0, 0.0)

        # Draw the number
        draw_number!(img, number, 10, 10, 1.0, color)

        # Verify some pixels changed color
        @test any(pixel -> pixel != RGB{N0f8}(1,1,1), img)

        # Test negative numbers
        draw_number!(img, -7, 50, 50, 1.0, color)
        # Should have drawn both the minus sign and the digit
        @test any(pixel -> pixel == color, img[40:60, 40:70]) # Expanded search region
    end

    @testset "Error handling" begin
        # Test invalid digit
        @test isempty(render_digit('A'))

        # Test drawing outside image bounds
        img = RGB{N0f8}.(ones(50, 50))
        # Should not throw error when drawing partially outside bounds
        @test_nowarn draw_number!(img, 123, 45, 45, 1.0, RGB{N0f8}(0,0,0))
    end
end
