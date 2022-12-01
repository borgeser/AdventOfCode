def get_food(file_name):
    with open(file_name, mode='r') as file:
        txt = file.read()
        elf_batches = txt.split("\n\n")
        elf_elems = [[int(calorie) for calorie in batch.split("\n")] for batch in elf_batches]
        return elf_elems


def part1(file_name):
    food = get_food(file_name)
    return max(sum(b) for b in food)


def part2(file_name):
    food = get_food(file_name)
    calories = sorted((sum(b) for b in food), reverse=True)
    return sum(calories[:3])


if __name__ == "__main__":
    print(part1('input.txt'))
    print(part2('input.txt'))
