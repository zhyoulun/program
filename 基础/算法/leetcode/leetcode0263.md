https://leetcode-cn.com/problems/ugly-number/


本题注意题目条件：丑数应为正整数

利用丑数只包含三个质因数，说明丑数除以拥有的质因数时会逐渐到1，否则不是丑数

```go
func isUgly(n int) bool {
	if n <= 0 {//丑数应为正整数
		return false
	}
	for n > 1 {
		if n%2 == 0 {
			n = n / 2
		} else if n%3 == 0 {
			n = n / 3
		} else if n%5 == 0 {
			n = n / 5
		} else {
			return false
		}
	}
	return true
}
```

测试

```go
func main() {
	for i := 1; i < 15; i++ {
		fmt.Println(i, isUgly(i))
	}
	isUgly(-2147483648)
}
```