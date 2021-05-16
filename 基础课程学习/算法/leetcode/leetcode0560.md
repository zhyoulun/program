https://leetcode-cn.com/problems/subarray-sum-equals-k/

```go
func subarraySum(nums []int, k int) int {
	result := 0
	for i := 0; i < len(nums); i++ {
		sum := 0
		for j := i; j < len(nums); j++ {
			sum += nums[j]
			if sum == k {
				result++
			}
		}
	}
	return result
}
```

```go

```

测试

```go
func main() {
	fmt.Println(subarraySum([]int{1, 1, 1}, 2))
}
```