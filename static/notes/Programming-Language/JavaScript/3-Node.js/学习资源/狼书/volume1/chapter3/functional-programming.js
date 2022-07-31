/**
 * @module functional-programming
 * @file 泛函式编程，函数工厂。本文件为一个纯粹的泛函式编程流程。
 * flow，流泛函，非常重要。多个函数依次操作一个对象。
 */

/** 函数工厂 map，返回转换数组的规则函数。
 * @param {Function} fn 传入一个函数，该函数是改造数组每个元素的规则
 * @returns {Function} map(fn)(array) 等价于 array.map(fn)
 */
const map = fn => array => array.map(fn);

/** 函数工厂 prop，返回由 key 获取对象 value 的函数。
 * @param {*} key 
 * @returns {Function} prop(key)(object) 等价于 object[key]
 */
const prop = key => object => object[key];

/** 函数工厂 reduce，返回转换数组的规则函数
 * @param  {Function} fn 累计规则函数
 * @param  {} initial 初始值
 * @returns {Function} reduce(fn, initial)(array) 等价于 array.reduce(fn, initial)
 */
const reduce = (fn, initial) => array => array.reduce(fn, initial);

/** 函数工厂 add，返回广义加法函数
 * @param  {*} x
 * @param  {*} y
 * @returns {Function} add(x, y) 等价于 x + y
 */
const add = (x, y) => x + y;

/** 函数 sum(array)，由函数工厂 reduce(fn, initial) 得出。sum(array) 等价于 array.reduce(add, 0)
 * @param  {Array} array
 * @returns {} 
 */
const sum = reduce(add, 0);

/** 函数工厂 filter，返回筛选数组的规则函数
 * @param  {Function} fn 该函数是筛选元素的规则
 * @returns {Function} filter(fn)(array) 等价于 array.filter(fn)
 */
const filter = fn => array => array.filter(fn);

/** 求平均值的函数
 * @param  {Array} items
 */
const average = items => items.length === 0 ? 0 : sum(items) / items.length;

/** 函数工厂 flow, flow(...fns) 返回一个流函数，flow(...fns)(x) 等价于 ...fns 中的若干个函数依次作用于 x
 * @param  {Array} ...fns 若干个函数
 */
const flow = (...fns) => x => fns.reduce((result, fn) => fn(result), x);

/** 计算商品平均成本的二元函数
 * @param  {Array} items 条目数组，每个条目都有 price 属性
 * @param  {Function} filterFn 筛选规则，默认值为统计所有条目
 * @returns {number} flow 参数中的若干个函数依次作用于 items，即先按照filterFn这个规则筛选、再转换为其价格数组、再求平均值
 */
const calcAvgCost =
  (items, filterFn = () => true) =>
    flow(
      filter(filterFn),
      map(prop('price')),
      average
    )(items);



const items = [
  { name: 'MotherBoard', manufacturer: 'A', price: 65 },
  { name: 'CPU', manufacturer: 'A', price: 240 },
  { name: 'DRAM', manufacturer: 'B', price: 100 },
  { name: 'CPU', manufacturer: 'B', price: 150 }
];

const avgCost = calcAvgCost(items); // 第二个参数使用默认值
const avgCostCPU = calcAvgCost(items, item => item.name === 'CPU');
const avgCostB = calcAvgCost(items, item => item.manufacturer === 'B');
const avgCostCPUFromA = calcAvgCost(items, item => item.name === 'CPU' && item.manufacturer === 'A');

console.log(avgCost);
console.log(avgCostCPU);
console.log(avgCostB);
console.log(avgCostCPUFromA);