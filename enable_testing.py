import sys, os, re

use_test = sys.argv[1].lower()

project_directory = os.path.dirname(__file__)

use_test_flag = "#if TEST"
dont_use_test_flag = "#if !TEST"

if use_test == "true":
    flags = [use_test_flag, dont_use_test_flag]
elif use_test == "false":
    flags = [dont_use_test_flag, use_test_flag]
else:
    exit("first argument must be either 'true' or 'false'")

print(f"will replace {flags[0]} with {flags[1]} in {project_directory}")

sources_directory = os.path.join(project_directory, "Sources")
tests_directory = os.path.join(project_directory, "Tests")

# the full paths to all of the swift source code files
# in the Sources and Tests directory, and the package.swift file
swift_files: [str] = []

package_file = os.path.join(project_directory, "Package.swift")
swift_files.append(package_file)

# search for all swift source code files
for directory in (sources_directory, tests_directory):
    for root, dirs, files in os.walk(directory):
        for file in files:
            if not file.endswith(".swift"):
                continue
            full_path = os.path.join(root, file)
            swift_files.append(full_path)

pattern = rf"^(\s*){flags[0]}\s*$"
replacement = rf"\1{flags[1]}"

for file in swift_files:
    # print(file)
    with open(file) as f:
        text = f.read()
    new_text = re.sub(pattern, replacement, text, flags=re.MULTILINE)
    with open(file, "w") as f:
        f.write(new_text)


