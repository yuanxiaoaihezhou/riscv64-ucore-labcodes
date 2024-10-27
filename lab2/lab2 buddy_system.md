# `buddy system` 2211133
## 头文件和宏定义
```c++
#include <pmm.h>
#include <list.h>
#include <string.h>
#include <buddy_system_pmm.h>
#include <stdio.h>

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)
#define left_child(parent) (2*parent+1)
#define right_child(parent) (2*parent+2)
#define parent(child) ((child-1)/2)
```
- `free_list`和`nr_free`表示空闲页链表和空闲页的数量
## 全局变量
```c++
extern free_area_t free_area;

unsigned int *buddy_tree; // 数组存储二叉树
int total_pages = 0; // 页总数
int tree_size = 0; // 数组大小
struct Page *base_page = NULL;
```
`free_area` 
`buddy_tree`  
`total_tree` 
`tree_size` 
`base_page` 
## 辅助函数
```c++
static int is_power_of_two(unsigned int n) {
    return (n & (n - 1)) == 0;
}
```
判断一个数是否为2的幂。如果一个数是2的幂，那么它的二进制表示中只有一个1。
```c++
static unsigned int log2(size_t n) {
    unsigned int order = 0;
    while (n >>= 1) {
        order++;
    }
    return order;
}
```
计算一个数的以2为底的对数。通过不断右移，直到数变为0，计算右移的次数。(下取整)
```c++
static size_t ceil_to_power_of_two(size_t n) {
    if (is_power_of_two(n)) {
        return n;
    }
    return 1 << (log2(n) + 1);
}

```
将一个数向上取整到最接近的2的幂。如果数已经是2的幂，直接返回；否则返回比它大的最小的2的幂。
```c++
static size_t floor_to_power_of_two(size_t n) {
    if (is_power_of_two(n)) {
        return n;
    }
    return 1 << log2(n);
}
```
将一个数向下取整到最接近的2的幂。如果数已经是2的幂，直接返回；否则返回比它小的最大的2的幂。
## 初始化函数
```c++
static void buddy_system_init(void) {
    list_init(&free_list);
    nr_free = 0;
}
```
初始化空闲页链表和空闲页计数。
```c++
static void buddy_system_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);

    total_pages = floor_to_power_of_two(n); // 向下取整到最接近2的幂, 多余的页我们这里为了方便舍弃。
    tree_size = 2 * total_pages - 1; // 总结点数
    nr_free += total_pages;
    base_page = base;

    // 初始化每一页
    struct Page *page = base;
    for(; page != base + total_pages; page++) {
        assert(PageReserved(page));
        page->flags = page->property = 0;
        set_page_ref(page, 0);
        SetPageProperty(page);
    }
    base->property = total_pages;

    // 初始化树
    buddy_tree = (unsigned int *)(base + total_pages);
    cprintf("\n-----------------Buddy System Initialized!------------------\n\n");
    cprintf("Base page address: %p, Total pages: %d\n", base, total_pages);
    cprintf("Buddy tree address: %p, Tree size: %d\n", buddy_tree, tree_size);

    // 填充每个节点管理的空闲页数
    unsigned int node_size = total_pages;
    buddy_tree[0] = total_pages;
    for(int i = 1; i < tree_size; i++) {
        if (is_power_of_two(i+1)) { // i是该层最后一个节点
            node_size /= 2;
        }
        buddy_tree[i] = node_size;
    }
}
```
初始化内存映射。     
对于`total_pages`，我们选择向下取整到最接近2的幂，舍弃多余的页，并更新空闲页数，同时保存内存页的起始地址。       
接下来，初始化每页，清除标志位和属性，并设置页的引用计数为0。设置基页的属性为`total_pages`以表示页块的大小。   
最后，我们初始化树节点，我们将`node_size`初始化为`total_pages`，并设置根节点管理的页数`buddy_tree[0]`为`total_pages`。然后从`i=1`开始遍历，每到新的一行将`node_size`减半。
## 内存分配函数
```c++
static struct Page *buddy_system_alloc_pages(size_t n) {
    assert(n > 0);
    unsigned int size = ceil_to_power_of_two(n);;
    unsigned int index = 0;
    unsigned int node_size;
    unsigned int offset = 0;
    struct Page *page = NULL;

    if (buddy_tree[index] < size) {
        return NULL;
    }

    // 找到合适的节点
    for (node_size = total_pages; node_size != size; node_size /= 2) {
        if (buddy_tree[left_child(index)] >= size) {
            index = left_child(index);
        } else {
            index = right_child(index);
        }
    }

    // 标记节点为已分配
    buddy_tree[index] = 0;
    offset = (index + 1) * node_size - total_pages;

    // 更新父节点的空闲页数
    while (index) {
        index = parent(index);
        buddy_tree[index] = (buddy_tree[left_child(index)] > buddy_tree[right_child(index)]) ?
                            buddy_tree[left_child(index)] : buddy_tree[right_child(index)];
    }

    // 返回分配的页
    page = base_page + offset;
    page->property = size;
    for (struct Page *p = page; p < page + size; p++) {
        ClearPageProperty(p);
    }
    nr_free -= size;
    cprintf("Allocated page address: %p, Requested size: %d, Allocated size: %d\n", page, n, size);
    return page;
}
```
首先，我们将`n`向上取整到最接近的2的幂，因为分配的内存块大小总是2的幂。      
接下来，我们初始化索引，当前节点管理的大小，内存偏移量和分配的页的起始地址，并检查根节点是否足够大（根节点存的是最大的页数，再大就无法分配了）。      
将`node_size`初始化为`total_pages`，然后循环，首先是根节点，根节点大于优先选择左节点，然后继续比较，直到`node_size`即`buddy_tree[index]`等于`size`。   
然后我们标记相应节点已分配（标记为0），再计算偏移量。     
接下来，我们更新父节点的空闲页数（即左右子节点较大的空闲页数）。       
最后，我们返回分配的页。
## 内存释放函数
```c++
static void buddy_system_free_pages(struct Page *free_page, size_t n) {
    unsigned int size = ceil_to_power_of_two(n);
    assert(size > 0);

    // 重置页为空闲状态
    struct Page *page = free_page;
    for (; page != free_page + size; page++) {
        assert(!PageReserved(page) && !PageProperty(page));
        page->flags = 0;
        set_page_ref(page, 0);
    }
    nr_free += size;
    cprintf("Freed page address: %p, Requested size: %d, Freed size: %d\n", free_page, n, size);

    // 找到对应的buddy_tree节点
    unsigned int node_size = 1;
    unsigned int offset = free_page - base_page;
    unsigned int index = offset + total_pages - 1;

    while (buddy_tree[index]) {
        node_size *= 2;
        if (index == 0) break;
        index = parent(index);
    }
    buddy_tree[index] = node_size;

    // 合并空闲块
    unsigned int left_size, right_size;
    while (index) {
        index = parent(index);
        node_size *= 2;
        left_size = buddy_tree[left_child(index)];
        right_size = buddy_tree[right_child(index)];
        if (left_size + right_size == node_size) {
            buddy_tree[index] = node_size;
        } else {
            buddy_tree[index] = (left_size > right_size) ? left_size : right_size;
        }
    }
}
```
首先，我们还是先上取整需要释放的页面数量。      



