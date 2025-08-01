import Nat "mo:core/Nat";
import PeekableIter "../src/PeekableIter";
import { test } "mo:test";

test(
  "fromIter",
  func() {
    let vals = [1, 2, 3].vals();
    let peekable = PeekableIter.fromIter<Nat>(vals);

    assert peekable.peek() == ?1;
    assert peekable.next() == ?1;

    assert peekable.peek() == ?2;
    assert peekable.peek() == ?2;
    assert peekable.next() == ?2;

    assert peekable.peek() == ?3;
    assert peekable.next() == ?3;

    assert peekable.peek() == null;
    assert peekable.next() == null;
  },
);

test(
  "hasNext",
  func() {
    let vals = [1, 2].vals();
    let peekable = PeekableIter.fromIter(vals);

    assert PeekableIter.hasNext(peekable); // true
    let _ = peekable.next(); // consume 1

    assert PeekableIter.hasNext(peekable); // true
    let _ = peekable.next(); // consume 2

    assert not PeekableIter.hasNext(peekable); // false

    // Test with empty iterator
    let empty = [].vals();
    let emptyPeekable = PeekableIter.fromIter(empty);
    assert not PeekableIter.hasNext(emptyPeekable); // false
  },
);

test(
  "isNext",
  func() {
    let vals = [42, 100].vals();
    let peekable = PeekableIter.fromIter(vals);

    assert PeekableIter.isNext(peekable, 42, Nat.equal); // true
    assert not PeekableIter.isNext(peekable, 100, Nat.equal); // false (next is 42)

    let _ = peekable.next(); // consume 42
    assert PeekableIter.isNext(peekable, 100, Nat.equal); // true

    // Test with empty iterator
    let empty = [].vals();
    let emptyPeekable = PeekableIter.fromIter(empty);
    assert not PeekableIter.isNext(emptyPeekable, 42, Nat.equal); // false
  },
);
