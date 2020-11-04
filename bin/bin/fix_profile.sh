#!/bin/bash

for file in $(ls *report); do
    echo "BRG = ${file}"
    old_profile=$(grep Profile ${file})
    echo "Old profile = ${old_profile}"
    profile=$(grep Profile ${file})

    IFS='_' read -ra prof_array <<< "${file}"
    # echo "0 = ${prof_array[0]}"
    # echo "1 = ${prof_array[1]}"
    # echo "2 = ${prof_array[2]}"
    # echo "3 = ${prof_array[3]}"
    # echo "4 = ${prof_array[4]}"

    new_profile="Profile: ${prof_array[0]}_${prof_array[1]}_${prof_array[2]}_${prof_array[3]}_${prof_array[4]}"
    echo "New profile = ${new_profile}"
    echo

    sed -i "s/${old_profile}/${new_profile}/g" ${file}

    # Desire: nasft_power_governor_240_1
done
