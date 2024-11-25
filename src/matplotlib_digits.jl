module MatplotlibDigits

using Colors: RGB, N0f8

# These are actual character outlines from a common sans-serif font
# Each digit is defined as a series of commands:
# M = moveto, L = lineto, C = curveto (cubic bezier), Z = closepath
const DIGIT_PATHS = Dict(
    '0' => [
        ('M', 4.0, 1.5),  # Move to start
        ('C', 2.0, 1.5, 0.5, 3.5, 0.5, 7.0),  # Left curve
        ('C', 0.5, 10.5, 2.0, 12.5, 4.0, 12.5),  # Bottom curve
        ('C', 6.0, 12.5, 7.5, 10.5, 7.5, 7.0),  # Right curve
        ('C', 7.5, 3.5, 6.0, 1.5, 4.0, 1.5),  # Top curve
        ('Z',)  # Close path
    ],
    '1' => [
        ('M', 2.5, 10.0),  # Move to start
        ('L', 4.0, 1.5),   # Diagonal up
        ('L', 4.0, 12.5),  # Vertical down
        ('Z',)  # Close path
    ],
    '2' => [
        ('M', 1.0, 3.5),
        ('C', 1.0, 2.0, 2.0, 1.5, 3.5, 1.5),
        ('C', 5.0, 1.5, 7.0, 2.0, 7.0, 4.0),
        ('C', 7.0, 8.0, 1.0, 9.0, 1.0, 12.5),
        ('L', 7.0, 12.5),
        ('Z',)
    ],
    '3' => [
        ('M', 1.0, 3.0),
        ('C', 1.0, 2.0, 2.0, 1.5, 3.5, 1.5),
        ('C', 5.0, 1.5, 7.0, 2.5, 7.0, 4.0),
        ('C', 7.0, 5.5, 6.0, 6.5, 4.5, 7.0),
        ('C', 6.0, 7.5, 7.0, 8.5, 7.0, 10.0),
        ('C', 7.0, 11.5, 5.0, 12.5, 3.5, 12.5),
        ('C', 2.0, 12.5, 1.0, 12.0, 1.0, 11.0),
        ('Z',)
    ],
    '4' => [
        ('M', 5.5, 1.5),
        ('L', 1.0, 8.5),
        ('L', 7.5, 8.5),
        ('L', 7.5, 12.5),
        ('M', 5.5, 1.5),
        ('L', 5.5, 12.5),
        ('Z',)
    ],
    '5' => [
        ('M', 6.5, 1.5),
        ('L', 2.0, 1.5),
        ('L', 1.5, 7.0),
        ('C', 2.0, 6.5, 3.0, 6.0, 4.0, 6.0),
        ('C', 5.5, 6.0, 7.0, 7.0, 7.0, 9.5),
        ('C', 7.0, 11.5, 5.5, 12.5, 3.5, 12.5),
        ('C', 2.0, 12.5, 1.0, 12.0, 1.0, 11.0),
        ('Z',)
    ],
    '6' => [
        ('M', 6.5, 2.0),
        ('C', 5.5, 1.5, 4.5, 1.5, 3.5, 1.5),
        ('C', 2.0, 1.5, 0.5, 3.0, 0.5, 7.0),
        ('C', 0.5, 11.0, 2.0, 12.5, 4.0, 12.5),
        ('C', 5.5, 12.5, 7.0, 11.5, 7.0, 9.5),
        ('C', 7.0, 7.5, 5.5, 6.5, 4.0, 6.5),
        ('C', 3.0, 6.5, 2.0, 7.0, 1.5, 7.5),
        ('Z',)
    ],
    '7' => [
        ('M', 1.0, 1.5),
        ('L', 7.0, 1.5),
        ('L', 3.5, 12.5),
        ('M', 2.0, 5.5),
        ('L', 5.5, 5.5),
        ('Z',)
    ],
    '8' => [
        ('M', 4.0, 1.5),
        ('C', 2.0, 1.5, 0.5, 2.5, 0.5, 4.0),
        ('C', 0.5, 5.5, 2.0, 6.5, 4.0, 7.0),
        ('C', 6.0, 7.5, 7.5, 8.5, 7.5, 10.0),
        ('C', 7.5, 11.5, 6.0, 12.5, 4.0, 12.5),
        ('C', 2.0, 12.5, 0.5, 11.5, 0.5, 10.0),
        ('C', 0.5, 8.5, 2.0, 7.5, 4.0, 7.0),
        ('C', 6.0, 6.5, 7.5, 5.5, 7.5, 4.0),
        ('C', 7.5, 2.5, 6.0, 1.5, 4.0, 1.5),
        ('Z',)
    ],
    '9' => [
        ('M', 1.5, 12.0),
        ('C', 2.5, 12.5, 3.5, 12.5, 4.5, 12.5),
        ('C', 6.0, 12.5, 7.5, 11.0, 7.5, 7.0),
        ('C', 7.5, 3.0, 6.0, 1.5, 4.0, 1.5),
        ('C', 2.5, 1.5, 1.0, 2.5, 1.0, 4.5),
        ('C', 1.0, 6.5, 2.5, 7.5, 4.0, 7.5),
        ('C', 5.0, 7.5, 6.0, 7.0, 6.5, 6.5),
        ('Z',)
    ]
)

function path_to_points(path, scale::Float64=1.0, steps::Int=30)
    points = Tuple{Float64,Float64}[]
    current_pos = (0.0, 0.0)

    for cmd in path
        if cmd[1] == 'M'  # Move to
            current_pos = (cmd[2] * scale, cmd[3] * scale)
            push!(points, current_pos)
        elseif cmd[1] == 'L'  # Line to
            new_pos = (cmd[2] * scale, cmd[3] * scale)
            for t in range(0, 1, length=steps)
                x = current_pos[1] + t * (new_pos[1] - current_pos[1])
                y = current_pos[2] + t * (new_pos[2] - current_pos[2])
                push!(points, (x, y))
            end
            current_pos = new_pos
        elseif cmd[1] == 'C'  # Cubic Bezier
            p1 = current_pos
            p2 = (cmd[2] * scale, cmd[3] * scale)
            p3 = (cmd[4] * scale, cmd[5] * scale)
            p4 = (cmd[6] * scale, cmd[7] * scale)

            for t in range(0, 1, length=steps)
                # Cubic Bezier formula
                x = (1-t)^3 * p1[1] +
                    3*(1-t)^2 * t * p2[1] +
                    3*(1-t) * t^2 * p3[1] +
                    t^3 * p4[1]
                y = (1-t)^3 * p1[2] +
                    3*(1-t)^2 * t * p2[2] +
                    3*(1-t) * t^2 * p3[2] +
                    t^3 * p4[2]
                push!(points, (x, y))
            end
            current_pos = p4
        end
    end
    points
end

function draw_digit!(img::AbstractMatrix, digit::Char, x::Int, y::Int,
                    scale::Float64=1.0, color=1)
    if !haskey(DIGIT_PATHS, digit)
        return
    end

    points = path_to_points(DIGIT_PATHS[digit], scale)
    height, width = size(img)

    # Draw with multiple passes for thickness
    thickness = 1.5  # Adjust this value to control line thickness
    for offset_x in -thickness:0.5:thickness
        for offset_y in -thickness:0.5:thickness
            for (px, py) in points
                ix = round(Int, px + x + offset_x)
                iy = round(Int, py + y + offset_y)
                if 1 <= ix <= width && 1 <= iy <= height
                    # Anti-aliasing with smoother falloff
                    dx = (px + x + offset_x - ix)
                    dy = (py + y + offset_y - iy)
                    dist = sqrt(dx^2 + dy^2)
                    intensity = max(0.0, min(1.0, (1.5 - dist/sqrt(2))))
                    # Blend colors using intensity
                    img[iy, ix] = RGB{N0f8}(
                        (1 - intensity) * convert(Float64, img[iy, ix].r) + intensity * color.r,
                        (1 - intensity) * convert(Float64, img[iy, ix].g) + intensity * color.g,
                        (1 - intensity) * convert(Float64, img[iy, ix].b) + intensity * color.b
                    )
                end
            end
        end
    end
end

function draw_number!(img::AbstractMatrix, number::Number, x::Int, y::Int,
                     scale::Float64=1.0, color=1)
    num_str = string(abs(number))
    offset = 0

    # Handle negative sign
    if number < 0
        for i in 1:round(Int, 4*scale)
            ix = x + i + offset
            iy = y + round(Int, 7*scale)
            if 1 <= ix <= size(img, 2) && 1 <= iy <= size(img, 1)
                img[iy, ix] = RGB{N0f8}(color.r, color.g, color.b)
            end
        end
        offset += round(Int, 8*scale)
    end

    # Draw each digit
    for digit in num_str
        draw_digit!(img, digit, x + offset, y, scale, color)
        offset += round(Int, 8*scale)  # Less spacing than previous version
    end
end

export draw_digit!, draw_number!, path_to_points, DIGIT_PATHS

end # module
