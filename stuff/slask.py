
def shaderFilter(iin, output_min, output_max):
    input_min = -1000
    input_max = 1000

    return (  ((iin - input_min) / (input_max - input_min)) * (output_max - output_min) + output_min    )


if __name__ == '__main__':
    print(shaderFilter(-758, -10, 7))
