![](/static/images/2008/p008.jpg)

- 车的类图结构为`<<abstract>>`，表示车是一个抽象类；
- 它有两个继承类：小汽车和自行车；它们之间的关系为实现关系，使用带空心箭头的虚线表示；
- 小汽车为与SUV之间也是继承关系，它们之间的关系为泛化关系，使用带空心箭头的实线表示；
- 小汽车与发动机之间是组合关系，使用带实心箭头的实线表示；
- 学生与班级之间是聚合关系，使用带空心箭头的实线表示；
- 学生与身份证之间为关联关系，使用一根实线表示；
- 学生上学需要用到自行车，与自行车是一种依赖关系，使用带箭头的虚线表示；

### 泛化关系(generalization)

类的继承结构表现在UML中为：泛化(generalize)与实现(realize)：

继承关系为 is-a的关系；两个对象之间如果可以用 is-a 来表示，就是继承关系：（..是..)

eg：自行车是车、猫是动物

泛化关系用一条带空心箭头的直接表示；如下图表示（A继承自B）；

![](/static/images/2008/p009.jpg)

eg：汽车在现实中有实现，可用汽车定义具体的对象；汽车与SUV之间为泛化关系；

![](/static/images/2008/p010.jpg)

注：最终代码中，泛化关系表现为继承非抽象类；

### 实现关系(realize)

实现关系用一条带空心箭头的虚线表示；

eg：”车”为一个抽象概念，在现实中并无法直接用来定义对象；只有指明具体的子类(汽车还是自行车)，才 可以用来定义对象（”车”这个类在C++中用抽象类表示，在JAVA中有接口这个概念，更容易理解）

![](/static/images/2008/p011.jpg)

注：最终代码中，实现关系表现为继承抽象类；

### 聚合关系(aggregation)

聚合关系用一条带空心菱形箭头的直线表示，如下图表示A聚合到B上，或者说B由A组成；

![](/static/images/2008/p012.jpg)

聚合关系用于表示实体对象之间的关系，表示整体由部分构成的语义；例如一个部门由多个员工组成；

与组合关系不同的是，整体和部分不是强依赖的，即使整体不存在了，部分仍然存在；例如， 部门撤销了，人员不会消失，他们依然存在；

### 组合关系(composition)

组合关系用一条带实心菱形箭头直线表示，如下图表示A组成B，或者B由A组成；

![](/static/images/2008/p013.jpg)

与聚合关系一样，组合关系同样表示整体由部分构成的语义；比如公司由多个部门组成；

但组合关系是一种强依赖的特殊聚合关系，如果整体不存在了，则部分也不存在了；例如， 公司不存在了，部门也将不存在了；

### 关联关系(association)

关联关系是用一条直线表示的；它描述不同类的对象之间的结构关系；它是一种静态关系， 通常与运行状态无关，一般由常识等因素决定的；它一般用来定义对象之间静态的、天然的结构； 所以，关联关系是一种“强关联”的关系；

比如，乘车人和车票之间就是一种关联关系；学生和学校就是一种关联关系；

关联关系默认不强调方向，表示对象间相互知道；如果特别强调方向，如下图，表示A知道B，但 B不知道A；

![](/static/images/2008/p014.jpg)

注：在最终代码中，关联对象通常是以成员变量的形式实现的；

### 依赖关系(dependency)

依赖关系是用一套带箭头的虚线表示的；如下图表示A依赖于B；他描述一个对象在运行期间会用到另一个对象的关系；

![](/static/images/2008/p015.jpg)

与关联关系不同的是，它是一种临时性的关系，通常在运行期间产生，并且随着运行时的变化； 依赖关系也可能发生变化；

显然，依赖也有方向，双向依赖是一种非常糟糕的结构，我们总是应该保持单向依赖，杜绝双向依赖的产生；

注：在最终代码中，依赖关系体现为类构造方法及类方法的传入参数，箭头的指向为调用关系；依赖关系除了临时知道对方外，还是“使用”对方的方法和属性；




## 参考

- [看懂UML类图和时序图](https://design-patterns.readthedocs.io/zh_CN/latest/read_uml.html)
- [组件图中的关系](https://www.ibm.com/support/knowledgecenter/zh/SSCLKU_7.5.5/com.ibm.xtools.modeler.doc/topics/crelsme_compd.html)
- [关系类型](https://www.ibm.com/support/knowledgecenter/zh/SS4JE2_7.5.5/com.ibm.xtools.modeler.doc/topics/rreltyp.html)




拗口的名词解释：

- 泛化关系：表示一个模型元素是另一个模型元素的特例化
- 实现关系：
  - 在 UML 图中，实现关系是类元与提供的接口之间的私有类型的实现关系。实现关系指定在实现类元时必须遵守提供的接口指定的合同。
  - 在 UML 建模中，如果一个模型元素（客户）实现另一个模型元素（供应者）指定的行为，那么这两个元素之间就存在实现关系。多个客户可以实现单个供应者的行为。可以在类图和组件图中使用实现关系。
- 组合关系：组合关系是一种表示整体与部分的关系的聚集。组合关系指定部分类元的生存期取决于完整类元的生存期。
- 关联关系：关联关系是两个模型元素之间的一种结构关系，它表示一个类元（参与者、用例、类、接口、节点或组件）的对象连接至另一个类元的对象，并且可浏览至这些对象。即使在双向关系中，关联也将连接两个类元，一个是主类元（供应者），另一个是辅助类元（客户）。
- 依赖关系：依赖关系表示更改一个模型元素（供应者或独立模型元素）会导致更改另一个模型元素（客户或从属模型元素）。供应者模型元素是独立的，这是因为更改客户并不会影响该模型元素。客户模型元素依赖于供应者模型元素，这是因为更改供应者将影响客户。