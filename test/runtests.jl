using Test
using CompUseTools

@testset "CompUseTools.jl" begin
    # Basic package loading test
    @test isdefined(CompUseTools, :CompUseTools)

    # Include other test files as they are created
    include("test_image_tools.jl")
    include("test_pixel_digits.jl")
    # include("browser_tests.jl")
    # include("html_tests.jl")
end
