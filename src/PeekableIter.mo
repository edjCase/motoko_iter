import Iter "mo:base/Iter";

module {
    /// Peekable Iterator Type.
    public type PeekableIter<T> = Iter.Iter<T> and {
        peek : () -> ?T;
    };

    /// Creates a `PeekableIter` from an existing `Iter`.
    /// The `peek` method returns the next value without advancing the peekable iterator,
    /// NOTE: the underlying iterator is advanced when `peek` is called by 1 if not already peeked.
    ///
    /// ### Example
    /// ```motoko
    /// let iter = Iter.fromArray([1, 2, 3]);
    /// let peekable = PeekableIter.fromIter(iter);
    /// assert(peekable.peek() == ?1); // Peek the first element
    /// assert(peekable.next() == ?1); // Get the first element
    /// assert(peekable.peek() == ?2); // Peek the second element
    /// assert(peekable.next() == ?2); // Get the second element
    /// assert(peekable.peek() == ?3); // Peek the third element
    /// assert(peekable.next() == ?3); // Get the third element
    /// assert(peekable.peek() == null); // No more elements to peek
    /// assert(peekable.next() == null); // No more elements to get
    /// ```
    public func fromIter<T>(iter : Iter.Iter<T>) : PeekableIter<T> {
        var peekItem : ?T = null;

        return object {
            public func peek() : ?T {
                switch (peekItem) {
                    case (?val) ?val;
                    case (null) {
                        // If we don't have a peeked value, get the next item from the iterator
                        // and store it for future calls to peek and next.
                        let next = iter.next();
                        peekItem := next;
                        next;
                    };
                };
            };

            public func next() : ?T {
                switch (peekItem) {
                    case (?val) ?val; // If we have a peeked value, return it
                    case (null) iter.next(); // Otherwise, just call next on the underlying iterator
                };
            };
        };
    };

    /// Checks if the iterator has a next value without advancing it.
    /// NOTE: the underlying iterator is advanced when `peek` is called by 1 if not already peeked.
    ///
    /// ### Example
    /// ```motoko
    /// let iter = PeekableIter.fromIter(Iter.fromArray([1, 2, 3]));
    /// assert(PeekableIter.hasNext(iter)); // true
    /// assert(iter.peek() == ?1); // Peek the first element
    /// assert(iter.next() == ?1); // Get the first element
    /// assert(PeekableIter.hasNext(iter)); // true
    /// assert(iter.peek() == ?2); // Peek the second element
    /// assert(iter.next() == ?2); // Get the second element
    /// assert(PeekableIter.hasNext(iter)); // true
    /// assert(iter.peek() == ?3); // Peek the third element
    /// assert(iter.next() == ?3); // Get the third element
    /// assert(not PeekableIter.hasNext(iter)); // false, no more elements
    /// assert(iter.peek() == null); // No more elements to peek
    /// assert(iter.next() == null); // No more elements to get
    /// ```
    public func hasNext<T>(iter : PeekableIter<T>) : Bool {
        switch (iter.peek()) {
            case (?_) { true };
            case (null) { false };
        };
    };

    /// Checks if the next value in the iterator is equal to the given value
    /// using the provided equality function.
    ///
    /// This method does not advance the peekable iterator.
    /// NOTE: the underlying iterator is advanced when `peek` is called by 1 if not already peeked.
    public func isNext<T>(iter : PeekableIter<T>, val : T, isEq : (T, T) -> Bool) : Bool {
        switch (iter.peek()) {
            case (?v) { isEq(v, val) };
            case (null) { false };
        };
    };
};
