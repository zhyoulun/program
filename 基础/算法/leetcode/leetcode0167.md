https://leetcode-cn.com/problems/two-sum-ii-input-array-is-sorted/

双指针法

```go
func twoSum(numbers []int, target int) []int {
	i := 0
	j := len(numbers) - 1
	for i < j {
		if numbers[i]+numbers[j] == target {
			return []int{i+1, j+1}
		} else if numbers[i]+numbers[j] < target {
			i++
		} else {
			j--
		}
	}
	return nil
}
```

测试

```go
func main() {
	fmt.Println(twoSum([]int{2,7,11,15}, 9))
	fmt.Println(twoSum([]int{2,3,4}, 6))
	fmt.Println(twoSum([]int{-1,0}, -1))
}
```