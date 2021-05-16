https://leetcode-cn.com/problems/two-sum/solution/liang-shu-zhi-he-by-leetcode-solution/

暴力法

```go
func twoSum(nums []int, target int) []int {
	for i := 0; i < len(nums)-1; i++ {
		for j := i + 1; j < len(nums); j++ {
			if nums[i]+nums[j] == target {
				return []int{i, j}
			}
		}
	}
	return nil
}
```

hash表缓存

```go
func twoSum(nums []int, target int) []int {
	cache := map[int][]int{}
	for k, v := range nums {
		if _, exist := cache[v]; !exist {
			cache[v] = make([]int, 0)
		}
		cache[v] = append(cache[v], k)
	}
	for value, indexArr := range cache {
		if _, exist := cache[target-value]; exist {
			if value == target-value {
				if len(indexArr) >= 2 {
					return []int{indexArr[0], indexArr[1]}
				}
			} else {
				return []int{cache[value][0], cache[target-value][0]}
			}
		}
	}
	return nil
}
```

更简洁的hash表缓存

```go
func twoSum(nums []int, target int) []int {
	cache := make(map[int]int, len(nums))
	for index1, v := range nums {
		if index2, exist := cache[target-v]; exist {
			return []int{index1, index2}
		} else {
			cache[v] = index1
		}
	}
	return nil
}
```