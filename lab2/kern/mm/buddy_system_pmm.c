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

extern free_area_t free_area;

unsigned int *buddy_tree; // 数组存储二叉树
int total_pages = 0; // 页总数
int tree_size = 0; // 数组大小
struct Page *base_page = NULL;

// 判断n是否为2的幂
static int is_power_of_two(unsigned int n) {
    return (n & (n - 1)) == 0;
}
// 计算n的以2为底的对数
static unsigned int log2(size_t n) {
    unsigned int order = 0;
    while (n >>= 1) {
        order++;
    }
    return order;
}
// 向上取整到最接近的2的幂
static size_t ceil_to_power_of_two(size_t n) {
    size_t result = 1;
    if (!is_power_of_two(n)) {
        while (n) {
            n >>= 1;
            result <<= 1;
        }
        return result;
    }
    return n;
}
// 向下取整到最接近的2的幂
static size_t floor_to_power_of_two(size_t n) {
    size_t result = 1;
    if (!is_power_of_two(n)) {
        while (n) {
            n >>= 1;
            result <<= 1;
        }
        return result >> 1;
    }
    return n;
}

// 初始化空闲页计数
static void buddy_system_init(void) {
    list_init(&free_list);
    nr_free = 0;
}

// 初始化buddy_tree和页
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

// 分配页
static struct Page *buddy_system_alloc_pages(size_t n) {
    assert(n > 0);
    unsigned int size = n;
    unsigned int index = 0;
    unsigned int node_size;
    unsigned int offset = 0;
    struct Page *page = NULL;

    // 将n向上取整到最接近的2的幂
    if (!is_power_of_two(size)) {
        size = ceil_to_power_of_two(size);
    }
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

// 释放页
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

// 打印buddy_tree
static void print_buddy_tree(void) {
    for (int i = 0; i < tree_size; i++) {
        cprintf("%d ", buddy_tree[i]);
        if (((i + 2) & (i + 1)) == 0) {
            cprintf("\n");
        }
    }
}

// 简化打印buddy_tree
static void simplified_print_tree(void) {
    int count = 1;
    for (int i = 0; i < tree_size; i++) {
        if (i + 1 < tree_size && buddy_tree[i] == buddy_tree[i + 1]) {
            count++;
        } else {
            cprintf("%d", buddy_tree[i]);
            if (count > 1) {
                cprintf("(%d)", count);
            }
            cprintf(" ");
            count = 1;
        }
        if (((i + 2) & (i + 1)) == 0) {
            cprintf("\n");
        }
    }
}

// 检查buddy_tree是否处于初始状态
static int is_initial_state(void) {
    int node_size = total_pages;
    for (int i = 0; i < tree_size; i++) {
        if (i != 0 && is_power_of_two(i + 1)) {
            node_size /= 2;
        }
        if (buddy_tree[i] != node_size) {
            cprintf("Buddy tree is not in initial state.\n");
            simplified_print_tree();
            return 0;
        }
    }
    cprintf("Buddy tree is in initial state.\n");
    return 1;
}

// 获取空闲页数
static size_t get_free_pages(void) {
    return nr_free;
}

// 检查buddy_tree的功能
static void buddy_check(void) {
    cprintf("\n-----------------Buddy Check Begins!------------------\n\n");
    simplified_print_tree();

    cprintf("\n---------------------First Check!---------------------\n\n");
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
    assert((p0 = alloc_page()) != NULL);
    simplified_print_tree();
    assert((p1 = alloc_page()) != NULL);
    simplified_print_tree();
    assert((p2 = alloc_page()) != NULL);
    simplified_print_tree();
    free_page(p0);
    simplified_print_tree();
    free_page(p1);
    simplified_print_tree();
    free_page(p2);
    is_initial_state();

    cprintf("\n---------------------Second Check!---------------------\n\n");
    struct Page *A, *B, *C, *D, *E;
    A = B = C = D = E = NULL;
    assert((A = alloc_pages(100)) != NULL);
    simplified_print_tree();
    assert((B = alloc_pages(240)) != NULL);
    simplified_print_tree();
    assert((C = alloc_pages(64)) != NULL);
    simplified_print_tree();
    assert((D = alloc_pages(253)) != NULL);
    simplified_print_tree();
    free_pages(B, 240);
    simplified_print_tree();
    free_pages(A, 100);
    simplified_print_tree();
    assert((E = alloc_pages(75)) != NULL);
    simplified_print_tree();
    free_pages(C, 64);
    simplified_print_tree();
    free_pages(E, 75);
    simplified_print_tree();
    free_pages(D, 253);
    is_initial_state();
}

const struct pmm_manager buddy_system_pmm_manager = {
    .name = "buddy_system_pmm_manager",
    .init = buddy_system_init,
    .init_memmap = buddy_system_init_memmap,
    .alloc_pages = buddy_system_alloc_pages,
    .free_pages = buddy_system_free_pages,
    .nr_free_pages = get_free_pages,
    .check = buddy_check,
};
