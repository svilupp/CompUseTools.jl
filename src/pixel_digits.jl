module PixelDigits

using LinearAlgebra
using ImageDraw
using Colors: RGB, N0f8

struct DigitStroke
    points::Vector{Tuple{Float64, Float64}}
end

"""
    bezier_curve(p0, p1, p2, p3, steps=30)
Generate points along a cubic Bezier curve.
"""
function bezier_curve(p0::Tuple{Float64,Float64}, p1::Tuple{Float64,Float64},
                     p2::Tuple{Float64,Float64}, p3::Tuple{Float64,Float64},
                     steps::Int=30)
    points = Vector{Tuple{Float64,Float64}}(undef, steps)
    for t in range(0, 1, length=steps)
        x = (1-t)^3 * p0[1] + 3*(1-t)^2 * t * p1[1] +
            3*(1-t) * t^2 * p2[1] + t^3 * p3[1]
        y = (1-t)^3 * p0[2] + 3*(1-t)^2 * t * p1[2] +
            3*(1-t) * t^2 * p2[2] + t^3 * p3[2]
        points[round(Int, t * (steps-1) + 1)] = (x, y)
    end
    points
end

"""
    line_segment(p0, p1, steps=15)
Generate points along a straight line.
"""
function line_segment(p0::Tuple{Float64,Float64}, p1::Tuple{Float64,Float64}, steps::Int=15)
    points = Vector{Tuple{Float64,Float64}}(undef, steps)
    for t in range(0, 1, length=steps)
        x = p0[1] + t * (p1[1] - p0[1])
        y = p0[2] + t * (p1[2] - p0[2])
        points[round(Int, t * (steps-1) + 1)] = (x, y)
    end
    points
end

# Now define the digit strokes using the above functions
const DIGIT_STROKES = Dict{Char, Vector{Vector{Tuple{Float64,Float64}}}}()

# Initialize each digit's strokes
DIGIT_STROKES['0'] = [
    bezier_curve((8.0,1.0), (4.0,1.0), (1.0,4.0), (1.0,8.0)),
    bezier_curve((1.0,8.0), (1.0,12.0), (4.0,15.0), (8.0,15.0)),
    bezier_curve((8.0,15.0), (12.0,15.0), (15.0,12.0), (15.0,8.0)),
    bezier_curve((15.0,8.0), (15.0,4.0), (12.0,1.0), (8.0,1.0)),
    bezier_curve((8.0,4.0), (11.0,4.0), (12.0,6.0), (12.0,8.0)),
    bezier_curve((12.0,8.0), (12.0,10.0), (11.0,12.0), (8.0,12.0)),
    bezier_curve((8.0,12.0), (5.0,12.0), (4.0,10.0), (4.0,8.0)),
    bezier_curve((4.0,8.0), (4.0,6.0), (5.0,4.0), (8.0,4.0))
]

DIGIT_STROKES['1'] = [
    line_segment((8.0,1.0), (8.0,15.0)),
    line_segment((6.0,4.0), (8.0,1.0)),
    line_segment((8.0,1.0), (10.0,4.0)),
    line_segment((6.0,15.0), (10.0,15.0))
]

DIGIT_STROKES['2'] = [
    bezier_curve((2.0,5.0), (2.0,1.0), (5.0,1.0), (8.0,1.0)),
    bezier_curve((8.0,1.0), (12.0,1.0), (14.0,3.0), (14.0,6.0)),
    bezier_curve((14.0,6.0), (14.0,8.0), (12.0,10.0), (8.0,12.0)),
    bezier_curve((8.0,12.0), (4.0,14.0), (2.0,15.0), (2.0,15.0)),
    line_segment((2.0,15.0), (14.0,15.0))
]

DIGIT_STROKES['3'] = [
    bezier_curve((2.0,3.0), (2.0,1.0), (5.0,1.0), (8.0,1.0)),
    bezier_curve((8.0,1.0), (12.0,1.0), (14.0,3.0), (14.0,5.0)),
    bezier_curve((14.0,5.0), (14.0,7.0), (12.0,8.0), (8.0,8.0)),
    bezier_curve((8.0,8.0), (12.0,8.0), (14.0,9.0), (14.0,12.0)),
    bezier_curve((14.0,12.0), (14.0,14.0), (12.0,15.0), (8.0,15.0)),
    bezier_curve((8.0,15.0), (4.0,15.0), (2.0,13.0), (2.0,11.0))
]

DIGIT_STROKES['4'] = [
    line_segment((11.0,1.0), (11.0,15.0)),
    line_segment((2.0,11.0), (14.0,11.0)),
    bezier_curve((2.0,11.0), (2.0,10.0), (4.0,6.0), (8.0,1.0))
]

DIGIT_STROKES['5'] = [
    line_segment((2.0,1.0), (14.0,1.0)),
    line_segment((2.0,1.0), (2.0,7.0)),
    bezier_curve((2.0,7.0), (5.0,7.0), (14.0,7.0), (14.0,9.0)),
    bezier_curve((14.0,9.0), (14.0,14.0), (12.0,15.0), (8.0,15.0)),
    bezier_curve((8.0,15.0), (4.0,15.0), (2.0,13.0), (2.0,11.0))
]

DIGIT_STROKES['6'] = [
    bezier_curve((14.0,3.0), (14.0,1.0), (11.0,1.0), (8.0,1.0)),
    bezier_curve((8.0,1.0), (3.0,1.0), (2.0,4.0), (2.0,8.0)),
    bezier_curve((2.0,8.0), (2.0,12.0), (4.0,15.0), (8.0,15.0)),
    bezier_curve((8.0,15.0), (12.0,15.0), (14.0,13.0), (14.0,10.0)),
    bezier_curve((8.0,7.0), (11.0,7.0), (12.0,9.0), (12.0,11.0)),
    bezier_curve((12.0,11.0), (12.0,13.0), (10.0,14.0), (8.0,14.0)),
    bezier_curve((8.0,14.0), (6.0,14.0), (4.0,13.0), (4.0,11.0)),
    bezier_curve((4.0,11.0), (4.0,9.0), (6.0,7.0), (8.0,7.0))
]

DIGIT_STROKES['7'] = [
    line_segment((2.0,1.0), (14.0,1.0)),
    bezier_curve((14.0,1.0), (12.0,4.0), (8.0,10.0), (6.0,15.0)),
    line_segment((6.0,8.0), (12.0,8.0))
]

DIGIT_STROKES['8'] = [
    bezier_curve((8.0,1.0), (4.0,1.0), (2.0,3.0), (2.0,5.0)),
    bezier_curve((2.0,5.0), (2.0,7.0), (4.0,8.0), (8.0,8.0)),
    bezier_curve((8.0,8.0), (12.0,8.0), (14.0,7.0), (14.0,5.0)),
    bezier_curve((14.0,5.0), (14.0,3.0), (12.0,1.0), (8.0,1.0)),
    bezier_curve((8.0,8.0), (4.0,8.0), (2.0,10.0), (2.0,12.0)),
    bezier_curve((2.0,12.0), (2.0,14.0), (4.0,15.0), (8.0,15.0)),
    bezier_curve((8.0,15.0), (12.0,15.0), (14.0,14.0), (14.0,12.0)),
    bezier_curve((14.0,12.0), (14.0,10.0), (12.0,8.0), (8.0,8.0))
]

DIGIT_STROKES['9'] = [
    bezier_curve((2.0,13.0), (2.0,15.0), (5.0,15.0), (8.0,15.0)),
    bezier_curve((8.0,15.0), (13.0,15.0), (14.0,12.0), (14.0,8.0)),
    bezier_curve((14.0,8.0), (14.0,4.0), (12.0,1.0), (8.0,1.0)),
    bezier_curve((8.0,1.0), (4.0,1.0), (2.0,3.0), (2.0,6.0)),
    bezier_curve((8.0,9.0), (5.0,9.0), (4.0,7.0), (4.0,5.0)),
    bezier_curve((4.0,5.0), (4.0,3.0), (6.0,2.0), (8.0,2.0)),
    bezier_curve((8.0,2.0), (10.0,2.0), (12.0,3.0), (12.0,5.0)),
    bezier_curve((12.0,5.0), (12.0,7.0), (10.0,9.0), (8.0,9.0))
]

"""
    render_digit(digit::Char, scale::Float64=1.0)
Renders a single digit at the specified scale.
"""
function render_digit(digit::Char, scale::Float64=1.0)
    if !haskey(DIGIT_STROKES, digit)
        return Tuple{Float64,Float64}[]
    end

    points = Tuple{Float64,Float64}[]
    for stroke in DIGIT_STROKES[digit]
        append!(points, [(x*scale, y*scale) for (x,y) in stroke])
    end
    points
end

"""
    draw_number!(img::AbstractMatrix{<:RGB}, number::Int, x::Int, y::Int,
                scale::Float64=1.0, color::RGB{N0f8}=RGB{N0f8}(1.0, 0.0, 0.0))
Draw a complete number onto an RGB image at specified coordinates.
"""
function draw_number!(img::AbstractMatrix{<:RGB}, number::Int, x::Int, y::Int,
                     scale::Float64=1.0, color::RGB{N0f8}=RGB{N0f8}(1.0, 0.0, 0.0))
    num_str = string(abs(number))
    offset = 0

    # Draw negative sign if needed
    if number < 0
        for i in 1:round(Int, 8*scale)
            ix = x + i + offset
            iy = y + round(Int, 8*scale)
            if 1 <= ix <= size(img, 2) && 1 <= iy <= size(img, 1)
                img[iy, ix] = color
            end
        end
        offset += round(Int, 16*scale)
    end

    # Draw each digit
    for digit in num_str
        points = render_digit(digit, scale)
        for (px, py) in points
            ix, iy = round(Int, px + x + offset), round(Int, py + y)
            if 1 <= ix <= size(img, 2) && 1 <= iy <= size(img, 1)
                img[iy, ix] = color
            end
        end
        offset += round(Int, 16*scale)
    end
end

export draw_number!, render_digit

end # module
