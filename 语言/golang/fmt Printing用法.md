### verbs

General:

```
%v	the value in a default format
	when printing structs, the plus flag (%+v) adds field names
%#v	a Go-syntax representation of the value
%T	a Go-syntax representation of the type of the value
%%	a literal percent sign; consumes no value
```

Boolean:

```
%t	the word true or false
```

Integer:

```
%b	base 2
%c	the character represented by the corresponding Unicode code point
%d	base 10
%o	base 8
%O	base 8 with 0o prefix
%q	a single-quoted character literal safely escaped with Go syntax.
%x	base 16, with lower-case letters for a-f
%X	base 16, with upper-case letters for A-F
%U	Unicode format: U+1234; same as "U+%04X"
```

Floating-point and complex constituents:

```
%b	decimalless scientific notation with exponent a power of two,
	in the manner of strconv.FormatFloat with the 'b' format,
	e.g. -123456p-78
%e	scientific notation, e.g. -1.234456e+78
%E	scientific notation, e.g. -1.234456E+78
%f	decimal point but no exponent, e.g. 123.456
%F	synonym for %f
%g	%e for large exponents, %f otherwise. Precision is discussed below.
%G	%E for large exponents, %F otherwise
%x	hexadecimal notation (with decimal power of two exponent), e.g. -0x1.23abcp+20
%X	upper-case hexadecimal notation, e.g. -0X1.23ABCP+20
```

String and slice of bytes (treated equivalently with these verbs):

```
%s	the uninterpreted bytes of the string or slice
%q	a double-quoted string safely escaped with Go syntax
%x	base 16, lower-case, two characters per byte
%X	base 16, upper-case, two characters per byte
```

Slice:

```
%p	address of 0th element in base 16 notation, with leading 0x
```

Pointer:

```
%p	base 16 notation, with leading 0x
The %b, %d, %o, %x and %X verbs also work with pointers,
formatting the value exactly as if it were an integer.
```

### The default format for %v

```
bool:                    %t
int, int8 etc.:          %d
uint, uint8 etc.:        %d, %#x if printed with %#v
float32, complex64, etc: %g
string:                  %s
chan:                    %p
pointer:                 %p
```

For compound objects, the elements are printed using these rules, recursively, laid out like this:

```
struct:             {field0 field1 ...}
array, slice:       [elem0 elem1 ...]
maps:               map[key1:value1 key2:value2 ...]
pointer to above:   &{}, &[], &map[]
```

### Width and precision

Width is specified by an optional decimal number immediately preceding the verb. If absent, the width is whatever is necessary to represent the value. Precision is specified after the (optional) width by a period followed by a decimal number. If no period is present, a default precision is used. A period with no following number specifies a precision of zero. Examples:

```
%f     default width, default precision
%9f    width 9, default precision
%.2f   default width, precision 2
%9.2f  width 9, precision 2
%9.f   width 9, precision 0
```

Width and precision are measured in units of Unicode code points, that is, runes. (This differs from C's printf where the units are always measured in bytes.) Either or both of the flags may be replaced with the character '*', causing their values to be obtained from the next operand (preceding the one to format), which must be of type int.

For most values, width is the minimum number of runes to output, padding the formatted form with spaces if necessary.

For strings, byte slices and byte arrays, however, precision limits the length of the input to be formatted (not the size of the output), truncating if necessary. Normally it is measured in runes, but for these types when formatted with the %x or %X format it is measured in bytes.

For floating-point values, width sets the minimum width of the field and precision sets the number of places after the decimal, if appropriate, except that for %g/%G precision sets the maximum number of significant digits (trailing zeros are removed). For example, given 12.345 the format %6.3f prints 12.345 while %.3g prints 12.3. The default precision for %e, %f and %#g is 6; for %g it is the smallest number of digits necessary to identify the value uniquely.

For complex numbers, the width and precision apply to the two components independently and the result is parenthesized, so %f applied to 1.2+3.4i produces (1.200000+3.400000i).

### Other flags

```
+	always print a sign for numeric values;
	guarantee ASCII-only output for %q (%+q)
-	pad with spaces on the right rather than the left (left-justify the field)
#	alternate format: add leading 0b for binary (%#b), 0 for octal (%#o),
	0x or 0X for hex (%#x or %#X); suppress 0x for %p (%#p);
	for %q, print a raw (backquoted) string if strconv.CanBackquote
	returns true;
	always print a decimal point for %e, %E, %f, %F, %g and %G;
	do not remove trailing zeros for %g and %G;
	write e.g. U+0078 'x' if the character is printable for %U (%#U).
' '	(space) leave a space for elided sign in numbers (% d);
	put spaces between bytes printing strings or slices in hex (% x, % X)
0	pad with leading zeros rather than spaces;
	for numbers, this moves the padding after the sign
```

Flags are ignored by verbs that do not expect them. For example there is no alternate decimal format, so %#d and %d behave identically.

### Print function

For each Printf-like function, there is also a Print function that takes no format and is equivalent to saying %v for every operand. Another variant Println inserts blanks between operands and appends a newline.

### operand is interface{}

Regardless of the verb, if an operand is an interface value, the internal concrete value is used, not the interface itself. Thus:

```
var i interface{} = 23
fmt.Printf("%v\n", i)
```

will print 23.

### operands that implement certain interfaces

Except when printed using the verbs %T and %p, special formatting considerations apply for operands that implement certain interfaces. In order of application:

1. If the operand is a reflect.Value, the operand is replaced by the concrete value that it holds, and printing continues with the next rule.

2. If an operand implements the Formatter interface, it will be invoked. Formatter provides fine control of formatting.

3. If the %v verb is used with the # flag (%#v) and the operand implements the GoStringer interface, that will be invoked.

If the format (which is implicitly %v for Println etc.) is valid for a string (%s %q %v %x %X), the following two rules apply:

4. If an operand implements the error interface, the Error method will be invoked to convert the object to a string, which will then be formatted as required by the verb (if any).

5. If an operand implements method String() string, that method will be invoked to convert the object to a string, which will then be formatted as required by the verb (if any).

### compound operands

For compound operands such as slices and structs, the format applies to the elements of each operand, recursively, not to the operand as a whole. Thus %q will quote each element of a slice of strings, and %6.2f will control formatting for each element of a floating-point array.

示例

```golang
package main

import (
	"fmt"
	"os"
)

func main() {
	a := 1
	fmt.Fprintf(os.Stdout, "%q\n", a)
	b := []int{1, 2, 3}
	fmt.Fprintf(os.Stdout, "%q\n", b)
	c := []interface{}{[]int{1, 2, 3}, 2, 3}
	fmt.Fprintf(os.Stdout, "%q\n", c)
}
```

运行结果：

```
'\x01'
['\x01' '\x02' '\x03']
[['\x01' '\x02' '\x03'] '\x02' '\x03']
```

### byte slice

However, when printing a byte slice with a string-like verb (%s %q %x %X), it is treated identically to a string, as a single item.

示例：

```golang
package main

import (
	"fmt"
	"os"
)

func main() {
	a := []byte{'a', 'b'}
	fmt.Fprintf(os.Stdout, "%s\n", a)
}
```

运行结果：

```
ab
```

### 无穷递归问题

To avoid recursion in cases such as

```golang
type X string
func (x X) String() string { return Sprintf("<%s>", x) }
```

convert the value before recurring:

```golang
func (x X) String() string { return Sprintf("<%s>", string(x)) }
```

Infinite recursion can also be triggered by self-referential data structures, such as a slice that contains itself as an element, if that type has a String method. Such pathologies are rare, however, and the package does not protect against them.

When printing a struct, fmt cannot and therefore does not invoke formatting methods such as Error or String on unexported fields.

### Explicit argument indexes，显式设置参数顺序

In Printf, Sprintf, and Fprintf, the default behavior is for each formatting verb to format successive arguments passed in the call. However, the notation [n] immediately before the verb indicates that the nth one-indexed argument is to be formatted instead. The same notation before a '*' for a width or precision selects the argument index holding the value. After processing a bracketed expression [n], subsequent verbs will use arguments n+1, n+2, etc. unless otherwise directed.

For example,

```golang
fmt.Sprintf("%[2]d %[1]d\n", 11, 22)
```

will yield "22 11", while

```golang
fmt.Sprintf("%[3]*.[2]*[1]f", 12.0, 2, 6)
```

equivalent to

```golang
fmt.Sprintf("%6.2f", 12.0)
```

will yield " 12.00". Because an explicit index affects subsequent verbs, this notation can be used to print the same values multiple times by resetting the index for the first argument to be repeated:

```golang
fmt.Sprintf("%d %d %#[1]x %#x", 16, 17)
```

will yield "16 17 0x10 0x11".

Format errors:

If an invalid argument is given for a verb, such as providing a string to %d, the generated string will contain a description of the problem, as in these examples:

```
Wrong type or unknown verb: %!verb(type=value)
	Printf("%d", "hi"):        %!d(string=hi)
Too many arguments: %!(EXTRA type=value)
	Printf("hi", "guys"):      hi%!(EXTRA string=guys)
Too few arguments: %!verb(MISSING)
	Printf("hi%d"):            hi%!d(MISSING)
Non-int for width or precision: %!(BADWIDTH) or %!(BADPREC)
	Printf("%*s", 4.5, "hi"):  %!(BADWIDTH)hi
	Printf("%.*s", 4.5, "hi"): %!(BADPREC)hi
Invalid or invalid use of argument index: %!(BADINDEX)
	Printf("%*[2]d", 7):       %!d(BADINDEX)
	Printf("%.[2]d", 7):       %!d(BADINDEX)
```

All errors begin with the string "%!" followed sometimes by a single character (the verb) and end with a parenthesized description.

If an Error or String method triggers a panic when called by a print routine, the fmt package reformats the error message from the panic, decorating it with an indication that it came through the fmt package. For example, if a String method calls panic("bad"), the resulting formatted message will look like

```
%!s(PANIC=bad)
```

The %!s just shows the print verb in use when the failure occurred. If the panic is caused by a nil receiver to an Error or String method, however, the output is the undecorated string, "<nil>".

## 参考 

- [https://golang.org/pkg/fmt/](https://golang.org/pkg/fmt/)