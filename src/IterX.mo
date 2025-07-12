import Order "mo:new-base/Order";
import Nat "mo:new-base/Nat";
import Iter "mo:new-base/Iter";
import List "mo:new-base/List";
import Runtime "mo:new-base/Runtime";
import PeekableIter "PeekableIter";

module {

    /// Returns an iterator that accumulates elements into arrays with a size less that or equal to the given `size`.
    /// Will trap if `size` is 0.
    ///
    /// ### Example
    /// - An example grouping a iterator of integers into arrays of size `3`:
    ///
    /// ```motoko
    ///
    ///     let vals = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].vals();
    ///     let it = IterX.chunks(vals, 3);
    ///
    ///     assert it.next() == ?[1, 2, 3];
    ///     assert it.next() == ?[4, 5, 6];
    ///     assert it.next() == ?[7, 8, 9];
    ///     assert it.next() == ?[10];
    ///     assert it.next() == null;
    /// ```
    public func chunk<A>(iter : Iter.Iter<A>, chunkSize : Nat) : Iter.Iter<[A]> {
        if (chunkSize == 0) {
            return Runtime.trap("Size must be greater than 0");
        };
        let list = List.empty<A>();

        object {
            public func next() : ?[A] {
                var i = 0;

                label l while (i < chunkSize) {
                    let ?val = iter.next() else break l;
                    List.add(list, val);
                    i := i + 1;
                };

                if (List.size(list) == 0) {
                    null;
                } else {
                    let tmp = ?List.toArray(list);
                    List.clear(list);
                    tmp;
                };
            };
        };
    };

    /// Checks if two iterators are equal.
    ///
    /// ### Example
    ///
    /// ```motoko
    ///
    ///     let it1 = IterX.range(1, 10);
    ///     let it2 = IterX.range(1, 10);
    ///
    ///     assert IterX.equal(it1, it2, Nat.equal);
    ///
    ///     let it3 = IterX.range(1, 5);
    ///     let it4 = IterX.range(1, 10);
    ///
    ///     assert not IterX.equal(it3, it4, Nat.equal);
    /// ```
    public func equal<A>(
        iter1 : Iter.Iter<A>,
        iter2 : Iter.Iter<A>,
        isEq : (A, A) -> Bool,
    ) : Bool {

        switch ((iter1.next(), iter2.next())) {
            case ((?a, ?b)) {
                if (isEq(a, b)) {
                    equal<A>(iter1, iter2, isEq);
                } else {
                    false;
                };
            };
            case ((null, ?_)) false;
            case ((?_, null)) false;
            case ((null, null)) true;
        };

    };

    /// Return the index of an element in an iterator that matches a predicate.
    ///
    /// ### Example
    ///
    /// ```motoko
    ///
    ///     let vals = [1, 2, 3, 4, 5].vals();
    ///
    ///     let isEven = func( x : Int ) : Bool {x % 2 == 0};
    ///     let res = IterX.findIndex(vals, isEven);
    ///
    ///     assert res == ?1;
    /// ```
    public func findIndex<A>(iter : Iter.Iter<A>, predicate : (A) -> Bool) : ?Nat {
        var i = 0;
        for (val in iter) {
            if (predicate(val)) {
                return ?i;
            };
            i += 1;
        };
        return null;
    };

    /// Returns an iterator with the indices of all the elements that match the predicate.
    ///
    /// ### Example
    ///
    /// ```motoko
    ///
    ///     let vals = [1, 2, 3, 4, 5, 6].vals();
    ///
    ///     let isEven = func( x : Int ) : Bool {x % 2 == 0};
    ///     let res = IterX.findIndices(vals, isEven);
    ///
    ///     assert Iter.toArray(res) == [1, 3, 5];
    ///
    /// ```
    public func findIndices<A>(iter : Iter.Iter<A>, predicate : (A) -> Bool) : Iter.Iter<Nat> {
        var i = 0;
        return object {
            public func next() : ?Nat {
                for (val in iter) {
                    i += 1;

                    if (predicate(val)) {
                        return ?(i - 1);
                    };

                };

                return null;
            };
        };
    };

    /// Returns an flattened iterator with all the values in a nested array
    ///
    /// ### Example
    ///
    /// ```motoko
    ///
    ///     let arr = [[1], [2, 3], [4, 5, 6]];
    ///     let flattened = IterX.flatten(arr);
    ///
    ///     assert Iter.toArray(flattened) == [1, 2, 3, 4, 5, 6];
    /// ```
    public func flattenArray<A>(nestedArray : Iter.Iter<[A]>) : Iter.Iter<A> {
        Iter.flatten(
            Iter.map(
                nestedArray,
                func(arr : [A]) : Iter.Iter<A> {
                    arr.vals();
                },
            )
        );
    };

    /// Groups nearby elements into arrays based on result from the given function and returns them along with the result of elements in that group.
    ///
    /// ### Example
    ///
    /// ```motoko
    ///
    ///     let vals = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].vals();
    ///
    ///     let isFactorOf30 = func( x : Int ) : Bool {x % 30 == 0};
    ///     let groups = IterX.groupBy(vals, isFactorOf30);
    ///
    ///     assert Iter.toArray(groups) == [
    ///         ([1, 2, 3], true),
    ///         ([4], false),
    ///         ([5, 6], true),
    ///         ([7, 8, 9], false),
    ///         ([10], true)
    ///     ];
    ///
    /// ```
    public func groupBy<A, B>(iter : Iter.Iter<A>, pred : (A) -> Bool) : Iter.Iter<([A], Bool)> {
        let groupItemList = List.empty<A>();

        func nextGroup() : ?([A], Bool) {
            switch (iter.next()) {
                case (?val) {
                    if (List.size(groupItemList) == 0) {
                        List.add(groupItemList, val);
                        return nextGroup();
                    };

                    if (pred(List.get(groupItemList, 0)) == pred(val)) {
                        List.add(groupItemList, val);
                        nextGroup();
                    } else {
                        let arr = List.toArray(groupItemList);

                        List.clear(groupItemList);
                        List.add(groupItemList, val);

                        ?(arr, pred(arr[0]));
                    };
                };
                case (_) {
                    if (List.size(groupItemList) == 0) {
                        null;
                    } else {
                        let arr = List.toArray(groupItemList);

                        List.clear(groupItemList);

                        ?(arr, pred(arr[0]));
                    };
                };
            };
        };

        return object {
            public func next() : ?([A], Bool) {
                nextGroup();
            };
        };
    };

    /// Checks if all the elements in an iterator are sorted in ascending order
    /// that for every element `a` ans its proceding element `b`, `a <= b`.
    ///
    /// Returns true if iterator is empty
    ///
    /// #Example
    ///
    /// ```motoko
    /// import Nat "mo:base/Nat";
    ///
    ///     let a = [1, 2, 3, 4];
    ///     let b = [1, 4, 2, 3];
    ///     let c = [4, 3, 2, 1];
    ///
    /// assert IterX.isSorted(a.vals(), Nat.compare) == true;
    /// assert IterX.isSorted(b.vals(), Nat.compare) == false;
    /// assert IterX.isSorted(c.vals(), Nat.compare) == false;
    ///
    /// ```
    public func isSorted<A>(iter : Iter.Iter<A>, cmp : (A, A) -> Order.Order) : Bool {
        var prev = switch (iter.next()) {
            case (?n) { n };
            case (null) return true;
        };

        for (item in iter) {
            if (cmp(prev, item) == #greater) {
                return false;
            };
            prev := item;
        };

        true;
    };

    /// Checks if all the elements in an iterator are sorted in descending order
    ///
    /// Returns true if iterator is empty
    ///
    /// #Example
    ///
    /// ```motoko
    /// import Nat "mo:base/Nat";
    ///
    ///     let a = [1, 2, 3, 4];
    ///     let b = [1, 4, 2, 3];
    ///     let c = [4, 3, 2, 1];
    ///
    /// assert IterX.isSortedDesc(a.vals(), Nat.compare) == false;
    /// assert IterX.isSortedDesc(b.vals(), Nat.compare) == false;
    /// assert IterX.isSortedDesc(c.vals(), Nat.compare) == true;
    ///
    /// ```
    public func isSortedDesc<A>(iter : Iter.Iter<A>, cmp : (A, A) -> Order.Order) : Bool {
        var prev = switch (iter.next()) {
            case (?n) { n };
            case (null) return true;
        };

        for (item in iter) {
            if (cmp(prev, item) == #less) {
                return false;
            };
            prev := item;
        };

        true;
    };

    /// Returns a tuple of the minimum and maximum value in an iterator.
    /// The first element is the minimum, the second the maximum.
    ///
    /// A null value is returned if the iterator is empty.
    ///
    /// If the iterator contains only one element, then it is returned as both
    /// the minimum and the maximum.
    ///
    /// ### Example
    ///
    /// ```motoko
    ///
    ///     let vals = [8, 4, 6, 9].vals();
    ///     let minmax = IterX.minmax(vals);
    ///
    ///     assert minmax == ?(4, 9);
    /// ```
    ///
    /// - minmax on an empty iterator
    ///
    /// ```motoko
    ///
    ///     let vals = [].vals();
    ///     let minmax = IterX.minmax(vals);
    ///
    ///     assert minmax == null;
    /// ```
    /// - minmax on an iterator with one element
    ///
    /// ```motoko
    ///
    ///     let vals = [8].vals();
    ///     let minmax = IterX.minmax(vals);
    ///
    ///     assert minmax == ?(8, 8);
    /// ```
    public func minmax<A>(iter : Iter.Iter<A>, cmp : (A, A) -> Order.Order) : ?(A, A) {
        let (_min, _max) = switch (iter.next()) {
            case (?a) {
                switch (iter.next()) {
                    case (?b) {
                        switch (cmp(a, b)) {
                            case (#less) { (a, b) };
                            case (_) { (b, a) };
                        };
                    };
                    case (_) { (a, a) };
                };
            };
            case (_) {
                return null;
            };
        };

        var min = _min;
        var max = _max;

        for (val in iter) {
            if (cmp(val, min) == #less) {
                min := val;
            };

            if (cmp(val, max) == #greater) {
                max := val;
            };
        };

        ?(min, max)

    };

    /// Returns the nth element of an iterator.
    /// Consumes the first n elements of the iterator.
    ///
    /// ### Example
    ///
    /// ```motoko
    ///
    ///     let vals = [0, 1, 2, 3, 4, 5].vals();
    ///     let nth = IterX.nth(vals, 3);
    ///
    ///     assert nth == ?3;
    /// ```
    ///
    public func nth<A>(iter : Iter.Iter<A>, n : Nat) : ?A {
        let skippedIter = Iter.drop<A>(iter, n);
        return skippedIter.next();
    };

    /// Takes a partition function that returns `true` or `false`
    /// for each element in the iterator.
    /// The iterator is partitioned into a tuple of two arrays.
    /// The first array contains the elements all elements that
    /// returned `true` and the second array contains the elements
    /// that returned `false`.
    ///
    /// If the iterator is empty, it returns a tuple of two empty arrays.
    /// ### Example
    ///
    /// ```motoko
    ///
    ///     let vals = [0, 1, 2, 3, 4, 5].vals();
    ///     let isEven = func (n: Nat) : Bool { n % 2 == 0 };
    ///
    ///     let (even, odd) = IterX.partition(vals, isEven);
    ///
    ///     assert even == [0, 2, 4];
    ///     assert odd == [1, 3, 5];
    ///
    /// ```
    public func partition<A>(iter : Iter.Iter<A>, f : (A) -> Bool) : (Iter.Iter<A>, Iter.Iter<A>) {
        let firstGroup = List.empty<A>();
        let secondGroup = List.empty<A>();

        for (val in iter) {
            if (f(val)) {
                List.add(firstGroup, val);
            } else {
                List.add(secondGroup, val);
            };
        };

        (List.values(firstGroup), List.values(secondGroup));
    };

    /// Returns a tuple of iterators where the first element is the first n elements of the iterator, and the second element is the remaining elements.
    ///
    /// ### Example
    /// ```motoko
    ///
    ///     let iter = [1, 2, 3, 4, 5].vals();
    ///     let (left, right) = IterX.splitAt(iter, 3);
    ///
    ///     assert left.next() == ?1;
    ///     assert right.next() == ?4;
    ///
    ///     assert left.next() == ?2;
    ///     assert right.next() == ?5;
    ///
    ///     assert left.next() == ?3;
    ///
    ///     assert left.next() == null;
    ///     assert right.next() == null;
    /// ```
    public func splitAt<A>(iter : Iter.Iter<A>, n : Nat) : (Iter.Iter<A>, Iter.Iter<A>) {
        var left = Iter.toArray(Iter.take(iter, n)).vals();
        (left, iter);
    };

    /// Unzips an iterator of tuples into a tuple of arrays.
    ///
    /// ### Example
    /// ```motoko
    ///
    ///     let iter = [(1, 'a'), (2, 'b'), (3, 'c')].vals();
    ///     let (arr1, arr2) = IterX.unzip(iter);
    ///
    ///     assert arr1 == [1, 2, 3];
    ///     assert arr2 == ['a', 'b', 'c'];
    /// ```
    public func unzip<A, B>(iter : Iter.Iter<(A, B)>) : ([A], [B]) {
        var list1 = List.empty<A>();
        var list2 = List.empty<B>();

        for ((a, b) in iter) {
            List.add(list1, a);
            List.add(list2, b);
        };

        (List.toArray(list1), List.toArray(list2));
    };

    /// Returns a peekable iterator.
    /// The iterator has a `peek` method that returns the next value
    /// without consuming the iterator.
    ///
    /// ### Example
    /// ```motoko
    ///
    ///     let vals = Iter.fromArray([1, 2]);
    ///     let peekIter = IterX.toPeekable(vals);
    ///
    ///     assert peekIter.peek() == ?1;
    ///     assert peekIter.next() == ?1;
    ///
    ///     assert peekIter.peek() == ?2;
    ///     assert peekIter.peek() == ?2;
    ///     assert peekIter.next() == ?2;
    ///
    ///     assert peekIter.peek() == null;
    ///     assert peekIter.next() == null;
    /// ```
    public func toPeekable<T>(iter : Iter.Iter<T>) : PeekableIter.PeekableIter<T> {
        PeekableIter.fromIter<T>(iter);
    };

};
