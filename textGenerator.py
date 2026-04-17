import random
import glob
import re

def generate_stress_test(filename, num_chars, num_lines):
    chars = [chr(i) for i in range(0x20, 0x7F)] + ['\t']
    
    with open(filename, "w") as f:
        current_chars = 0
        for l in range(num_lines - 1):
            # Generate a random line length
            line_len = random.randint(10, 80)
            line = "".join(random.choice(chars) for _ in range(line_len)) + "\n"
            f.write(line)
            current_chars += len(line)
            if current_chars >= num_chars:
                break
        
        # Ensure we stay under limits
        print(f"Generated {filename}")

def generate_edge_case(filename):
    with open(filename, "w") as f:
        f.write("   \t\n") # Start with some whitespace
        f.write("Princeton") # Add a word
        f.write("  ") # Add more whitespace
        f.write("Tigers") # Add another word
        # end without newline

def auto_descriptions():
    files = glob.glob("mywc*.txt")

    allowed_pattern = re.compile(r'^[\x09\x0A\x20-\x7E]*$')

    for filename in files:
        with open(filename, 'r') as f:
            content = f.read()
            if allowed_pattern.match(content):
                print(f"{filename} is valid.")
            else:
                print(f"{filename} contains INVALID characters!")

if __name__ == "__main__":
    #generate_stress_test("mywc_stress_large.txt", 45000, 999)
    #generate_edge_case("mywc_statement.txt")
    auto_descriptions()
