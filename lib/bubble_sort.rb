def bubble_sort(arr)
    changed = true
    while changed
        changed = false
        arr.each_with_index do |value, index|
            if index > 0 && value < arr[index-1]
                temp_prev = arr[index-1]
                arr[index-1] = value
                arr[index] = temp_prev
                changed = true
            end
        end
    end
    arr
end

puts bubble_sort([4,3,78,2,0,2])