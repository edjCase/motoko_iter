import Iter "mo:core/Iter";
import Nat "mo:core/Nat";
import Int "mo:core/Int";
import Float "mo:core/Float";
import IterX "../src/IterX";
import { test } "mo:test";

test(
  "chunk",
  func() {
    let vals = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].vals();
    let it = IterX.chunk<Nat>(vals, 3);

    assert it.next() == ?[1, 2, 3];
    assert it.next() == ?[4, 5, 6];
    assert it.next() == ?[7, 8, 9];
    assert it.next() == ?[10];
    assert it.next() == null;
  },
);

test(
  "equal - two equal iterators",
  func() {
    let it1 = [1, 2, 3, 4, 5].vals();
    let it2 = [1, 2, 3, 4, 5].vals();

    assert IterX.equal(it1, it2, Nat.equal);
  },
);

test(
  "equal - two unequal iterators",
  func() {
    let it1 = [1, 2, 3, 4, 5].vals();
    let it2 = [1, 2, 3, 4, 5, 6].vals();

    assert not IterX.equal(it1, it2, Nat.equal);

    let it3 = [1, 2, 3, 4, 4].vals();

    assert not IterX.equal(it1, it3, Nat.equal);
  },
);

test(
  "findIndex",
  func() {
    let vals = [1, 2, 3, 4, 5].vals();

    let isEven = func(x : Int) : Bool { x % 2 == 0 };
    let res = IterX.findIndex<Int>(vals, isEven);

    assert res == ?1;
  },
);

test(
  "findIndices",
  func() {
    let vals = [1, 2, 3, 4, 5, 6, 7, 9].vals();

    let isEven = func(x : Int) : Bool { x % 2 == 0 };
    let iter = IterX.findIndices(vals, isEven);

    let res = Iter.toArray(iter);

    assert res == [1, 3, 5];
  },
);

test(
  "flattenArray",
  func() {
    let arr = [
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 9],
    ].vals();

    let flattened = IterX.flattenArray(arr);
    let res = Iter.toArray(flattened);

    assert res == [1, 2, 3, 4, 5, 6, 7, 8, 9];
  },
);

test(
  "groupBy",
  func() {
    let vals = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].vals();

    let isFactorOf30 = func(n : Int) : Bool {
      30.0 % Float.fromInt(n) == 0;
    };
    let groups = IterX.groupBy(vals, isFactorOf30);

    let res = Iter.toArray(groups);

    assert res == [
      ([1, 2, 3], true),
      ([4], false),
      ([5, 6], true),
      ([7, 8, 9], false),
      ([10], true),
    ];
  },
);

test(
  "isSorted",
  func() {
    let a = [1, 2, 3, 4];
    let b = [1, 4, 2, 3];
    let c = [4, 3, 2, 1];

    assert IterX.isSorted(a.vals(), Nat.compare);
    assert not IterX.isSorted(b.vals(), Nat.compare);
    assert not IterX.isSorted(c.vals(), Nat.compare);
  },
);

test(
  "isSortedDesc",
  func() {
    let a = [1, 2, 3, 4];
    let b = [1, 4, 2, 3];
    let c = [4, 3, 2, 1];

    assert not IterX.isSortedDesc(a.vals(), Nat.compare);
    assert not IterX.isSortedDesc(b.vals(), Nat.compare);
    assert IterX.isSortedDesc(c.vals(), Nat.compare);
  },
);

test(
  "minmax - find min and max",
  func() {
    let vals = [8, 4, 6, 9].vals();
    let minmax = IterX.minmax(vals, Nat.compare);

    assert minmax == ?(4, 9);
  },
);

test(
  "minmax - empty iterator returns null",
  func() {
    let vals = [].vals();
    let minmax = IterX.minmax(vals, Nat.compare);

    assert minmax == null;
  },
);

test(
  "minmax - single element",
  func() {
    let vals = [8].vals();
    let minmax = IterX.minmax(vals, Nat.compare);

    assert minmax == ?(8, 8);
  },
);

test(
  "nth",
  func() {
    let vals = [0, 1, 2, 3, 4, 5].vals();
    let nth = IterX.nth(vals, 3);

    assert nth == ?3;
  },
);

test(
  "partition",
  func() {
    let vals = [0, 1, 2, 3, 4, 5].vals();

    let isEven = func(n : Nat) : Bool { n % 2 == 0 };

    let (evenIter, oddIter) = IterX.partition(vals, isEven);
    let even = Iter.toArray(evenIter);
    let odd = Iter.toArray(oddIter);

    assert even == [0, 2, 4];
    assert odd == [1, 3, 5];
  },
);

test(
  "toPeekable",
  func() {
    let vals = [1, 2].vals();
    let peekIter = IterX.toPeekable(vals);

    assert peekIter.peek() == ?1;
    assert peekIter.next() == ?1;

    assert peekIter.peek() == ?2;
    assert peekIter.peek() == ?2;
    assert peekIter.next() == ?2;

    assert peekIter.peek() == null;
    assert peekIter.next() == null;
  },
);

test(
  "splitAt",
  func() {
    let iter = [1, 2, 3, 4, 5].vals();
    let (leftIter, rightIter) = IterX.splitAt(iter, 3);

    let left = Iter.toArray(leftIter);
    let right = Iter.toArray(rightIter);

    assert left == [1, 2, 3];
    assert right == [4, 5];
  },
);

test(
  "unzip",
  func() {
    let iter = [(1, 'a'), (2, 'b'), (3, 'c')].vals();
    let (arr1, arr2) = IterX.unzip(iter);

    assert arr1 == [1, 2, 3];
    assert arr2 == ['a', 'b', 'c'];
  },
);
