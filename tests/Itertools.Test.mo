import Char "mo:new-base/Char";
import Debug "mo:new-base/Debug";
import Iter "mo:new-base/Iter";
import Nat "mo:new-base/Nat";
import Nat8 "mo:new-base/Nat8";
import Nat32 "mo:new-base/Nat32";
import Int "mo:new-base/Int";
import Float "mo:new-base/Float";
import Func "mo:new-base/Func";
import Text "mo:new-base/Text";
import IterX "../src/IterX";
import PeekableIter "../src/PeekableIter";

let success = run([
    describe(
        "Iter",
        [
            it(
                "chunk",
                do {
                    let vals = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].vals();
                    let it = IterX.chunk<Nat>(vals, 3);

                    assertAllTrue([
                        it.next() == ?[1, 2, 3],
                        it.next() == ?[4, 5, 6],
                        it.next() == ?[7, 8, 9],
                        it.next() == ?[10],
                        it.next() == null,
                    ]);
                },
            ),
            it(
                "enumerate",
                do {
                    let chars = "abc".chars();
                    let iter = IterX.enumerate(chars);

                    assertAllTrue([
                        iter.next() == ?(0, 'a'),
                        iter.next() == ?(1, 'b'),
                        iter.next() == ?(2, 'c'),
                        iter.next() == null,
                    ]);
                },
            ),
            describe(
                "equal",
                [
                    it(
                        "two equal iters",
                        do {
                            let it1 = Iter.range(1, 5);
                            let it2 = Iter.range(1, 5);

                            assertTrue(
                                IterX.equal(it1, it2, Nat.equal)
                            );
                        },
                    ),

                    it(
                        "two unequal iters ",
                        do {
                            let it1 = Iter.range(1, 5);
                            let it2 = Iter.range(1, 10);

                            assertFalse(
                                IterX.equal(it1, it2, Nat.equal)
                            );
                        },
                    ),
                ],
            ),
            it(
                "findIndex",
                do {
                    let vals = [1, 2, 3, 4, 5].vals();

                    let isEven = func(x : Int) : Bool { x % 2 == 0 };
                    let res = IterX.findIndex<Int>(vals, isEven);

                    assertTrue(res == ?1);
                },
            ),
            it(
                "findIndices",
                do {
                    let vals = [1, 2, 3, 4, 5, 6, 7, 9].vals();

                    let isEven = func(x : Int) : Bool { x % 2 == 0 };
                    let iter = IterX.findIndices(vals, isEven);

                    let res = Iter.toArray(iter);

                    assertTrue(res == [1, 3, 5]);
                },
            ),
            it(
                "flattenArray",
                do {
                    let arr = [
                        [1, 2, 3],
                        [4, 5, 6],
                        [7, 8, 9],
                    ];

                    let flattened = IterX.flattenArray(arr);
                    let res = Iter.toArray(flattened);

                    assertTrue(res == [1, 2, 3, 4, 5, 6, 7, 8, 9])

                },
            ),
            it(
                "groupBy",
                do {
                    let vals = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].vals();

                    let isFactorOf30 = func(n : Int) : Bool {
                        30.0 % Float.fromInt(n) == 0;
                    };
                    let groups = IterX.groupBy(vals, isFactorOf30);

                    let res = Iter.toArray(groups);

                    assertTrue(
                        res == [
                            ([1, 2, 3], true),
                            ([4], false),
                            ([5, 6], true),
                            ([7, 8, 9], false),
                            ([10], true),
                        ]
                    );
                },
            ),
            it(
                "isSorted",
                do {
                    let a = [1, 2, 3, 4];
                    let b = [1, 4, 2, 3];
                    let c = [4, 3, 2, 1];

                    assertAllTrue([
                        IterX.isSorted(a.vals(), Nat.compare),
                        not IterX.isSorted(b.vals(), Nat.compare),
                        not IterX.isSorted(c.vals(), Nat.compare),
                    ]);
                },
            ),
            it(
                "isSortedDesc",
                do {
                    let a = [1, 2, 3, 4];
                    let b = [1, 4, 2, 3];
                    let c = [4, 3, 2, 1];

                    assertAllTrue([
                        not IterX.isSortedDesc(a.vals(), Nat.compare),
                        not IterX.isSortedDesc(b.vals(), Nat.compare),
                        IterX.isSortedDesc(c.vals(), Nat.compare),
                    ]);
                },
            ),
            describe(
                "minmax",
                [
                    it(
                        "find min and max",
                        do {
                            let vals = [8, 4, 6, 9].vals();
                            let minmax = IterX.minmax(vals, Nat.compare);

                            assertTrue(minmax == ?(4, 9));
                        },
                    ),
                    it(
                        "empty iter return null",
                        do {
                            let vals = [].vals();
                            let minmax = IterX.minmax(vals, Nat.compare);

                            assertTrue(minmax == null);
                        },
                    ),
                    it(
                        "minmax for iter with one element",
                        do {
                            let vals = [8].vals();
                            let minmax = IterX.minmax(vals, Nat.compare);

                            assertTrue(minmax == ?(8, 8));
                        },
                    ),
                ],
            ),
            it(
                "nth",
                do {
                    let vals = [0, 1, 2, 3, 4, 5].vals();
                    let nth = IterX.nth(vals, 3);

                    assertTrue(nth == ?3);
                },
            ),
            it(
                "partition",
                do {
                    let vals = [0, 1, 2, 3, 4, 5].vals();

                    let isEven = func(n : Nat) : Bool { n % 2 == 0 };

                    let (even, odd) = IterX.partition(vals, isEven);

                    assertAllTrue([
                        even == [0, 2, 4],
                        odd == [1, 3, 5],
                    ]);
                },
            ),
            it(
                "toPeekable",
                do {
                    let vals = [1, 2].vals();
                    let peekIter = IterX.toPeekable(vals);

                    assertAllTrue([
                        peekIter.peek() == ?1,
                        peekIter.next() == ?1,

                        peekIter.peek() == ?2,
                        peekIter.peek() == ?2,
                        peekIter.next() == ?2,

                        peekIter.peek() == null,
                        peekIter.next() == null,
                    ]);
                },
            ),
            it(
                "splitAt",
                do {
                    let iter = [1, 2, 3, 4, 5].vals();
                    let (leftIter, rightIter) = IterX.splitAt(iter, 3);

                    let (left, right) = (
                        Iter.toArray(leftIter),
                        Iter.toArray(rightIter),
                    );

                    assertAllTrue([
                        left == [1, 2, 3],
                        right == [4, 5],
                    ]);
                },
            ),
            it(
                "unzip",
                do {
                    let iter = [(1, 'a'), (2, 'b'), (3, 'c')].vals();
                    let (arr1, arr2) = IterX.unzip(iter);

                    assertAllTrue([
                        arr1 == [1, 2, 3],
                        arr2 == ['a', 'b', 'c'],
                    ]);
                },
            ),
            it(
                "toText",
                do {
                    let chars = "abc".chars();
                    let text = IterX.toText(chars, "");

                    assertTrue(text == "abc");
                },
            ),
        ],
    ),
]);

if (success == false) {
    Debug.trap("\1b[46;41mTests failed\1b[0m");
} else {
    Debug.print("\1b[23;42;3m Success!\1b[0m");
};
