#include <stdio.h>

// Recursive implementation of the binary search algorithm to return
// the position of `target` in subarray nums[low…high]
int binarySearch(int nums[], int low, int high, int target)
{
    // Base condition (search space is exhausted)
    if (low > high) {
        return -1;
    }

    // find the mid-value in the search space and
    // compares it with the target

    int mid = (low + high)/2;    // overflow can happen
    // int mid = low + (high - low)/2;

    // Base condition (target value is found)
    if (target == nums[mid]) {
        return mid;
    }

    // discard all elements in the right search space,
    // including the middle element
    else if (target < nums[mid]) {
        return binarySearch(nums, low, mid - 1, target);
    }

    // discard all elements in the left search space,
    // including the middle element
    else {
        return binarySearch(nums, mid + 1, high, target);
    }
}

int main(void)
{
    int nums[] = { 2, 5, 6, 8, 9, 10 };
    int target = 5;

    int n = sizeof(nums)/sizeof(nums[0]);

    int low = 0, high = n - 1;
    int index = binarySearch(nums, low, high, target);

    if (index != -1) {
        printf("Element found at index %d", index);
    }
    else {
        printf("Element not found in the array");
    }

    return 0;
}