#include <stdio.h>

// Iterative implementation of the binary search algorithm to return
// the position of `target` in array `nums` of size `n`
int binarySearch(int nums[], int n, int target)
{
    // search space is nums[low…high]
    int low = 0, high = n - 1;

    // loop till the search space is exhausted
    while (low <= high)
    {
        // find the mid-value in the search space and
        // compares it with the target

        int mid = (low + high)/2;    // overflow can happen
                                     // int mid = low + (high - low)/2;
                                     // int mid = high - (high - low)/2;

                                     // target value is found
        if (target == nums[mid]) {
            return mid;
        }

        // if the target is less than the middle element, discard all elements
        // in the right search space, including the middle element
        else if (target < nums[mid]) {
            high = mid - 1;
        }

        // if the target is more than the middle element, discard all elements
        // in the left search space, including the middle element
        else {
            low = mid + 1;
        }
    }

    // target doesn't exist in the array
    return -1;
}

int main(void)
{
    int nums[] = { 2, 5, 6, 8, 9, 10 };
    int target = 5;

    int n = sizeof(nums)/sizeof(nums[0]);
    int index = binarySearch(nums, n, target);

    if (index != -1) {
        printf("Element found at index %d", index);
    }
    else {
        printf("Element not found in the array");
    }

    return 0;
}