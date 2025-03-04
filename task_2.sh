#!/bin/bash

echo -e "Exercise 1\n"

# Get all lists in lists/ directory, fill all programs file
i=0
for file in lists/*; do
    cat $file >> programs
    if [[ $(grep "[^[:space:]]" $file) ]]; then
        let "i++"
    fi
done
echo "We got $i lists"

# Delete from all programs file *.src lines
sed -i '/\.src/d' programs

# Delete duplicates and save initial order
cat -n programs | sort -uk2 | sort -n | cut -f2- >> uniq_programs
echo "We got $(wc -l uniq_programs) unique programs"

# Clean not necessary files
rm programs uniq_programs

echo -e "\nExercise 2\n"

# Get all_programs from all.src_files
cat lists/all.src | while read line; do
    cat lists/$line >> programs
done

# Delete duplicates and save initial order
cat -n programs | sort -uk2 | sort -n | cut -f2- >> uniq_programs
echo "We got $(wc -l uniq_programs) for distro"

# Create associative array and size value
declare -A matrix
declare -i size=1

# Get size of matrix
size+=$(cat uniq_programs | wc -l)
declare -i i=1

while IFS= read -r line; do
    key="0,$i"
    matrix[$key]="$line"
    key="$i,0"
    matrix[$key]="$line"
    ((i=i+1))
done < uniq_programs

for ((i = 1; i < $size; i+=1)); do
    for ((j = 1; j < $size; j+=1)); do
        if grep -i -q $(matrix[0,$j]) deps/${matrix[$i,0]}.deps; then
            key="$i,$j"
            matrix[$key]='1'
        else
            key="$i,$j"
            matrix[$key]='0'
        fi
    done
done

wait

echo -e "\nOutput matrix:\n"
printf "|%s" "|_."
for ((i = 1; i < $size; i++)); do
    printf "|__%s" "${matrix[0,$i]}"
done
echo "|"

for ((i = 1; i < $size; i++)); do
    printf "|=. %s" "${matrix[$i,0]}"
    for ((j = 1; j < $size; j++)); do
        key="$i,$j"
        printf "|=. %s" "${matrix[$key]}"
    done
    echo "|"
done