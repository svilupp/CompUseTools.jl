using Test
using CompUseTools
using Aqua

@testset "CompUseTools.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(CompUseTools)
    end

    # Basic package loading test
    @test isdefined(CompUseTools, :CompUseTools)

    # Include other test files as they are created
    include("test_image_tools.jl")
    include("test_pixel_digits.jl")
    # include("browser_tests.jl")
    # include("html_tests.jl")
end
