function render_image(image, width, height)
    result = []
    for y in 0:(height - 1)
        for x in 0:(width - 1)
            i = (y * width + x) + 1
            n = image[i]
            push!(result, n == 0 ? " " : "#")
        end
        push!(result, "\n")
    end
    join(result)
end

function solve()
    input = read("res/day_08.txt", String)
    image_data = [parse(Int, x) for x in split(input, "")]

    width, height = 25, 6
    layer_size = width * height
    num_layers = convert(Int, floor(length(image_data) / layer_size))

    layers = map(collect(0:(num_layers - 1))) do layer_i
        start = layer_i * layer_size + 1
        image_data[start:(start + (layer_size - 1))]
    end

    counts = Dict(0 => Inf, 1 => 0, 2 => 0)
    for layer in layers
        new_counts = Dict(0 => 0, 1 => 0, 2 => 0)
        for n in layer
            new_counts[n] += 1
        end
        if new_counts[0] < counts[0]
            counts = new_counts
        end
    end

    part_one = counts[1] * counts[2]

    final_image = copy(layers[1])
    for i in 1:layer_size
        n = final_image[i]
        if (n != 2)
            continue
        end
        for layer in layers[2:end]
            if layer[i] != 2
                final_image[i] = layer[i]
                break
            end
        end
    end

    part_two = render_image(final_image, width, height)
    part_one, println(part_two)
end

solve()
