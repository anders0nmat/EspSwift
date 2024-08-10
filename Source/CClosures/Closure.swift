

/** A wrapper for calling Swift closures from C functions

	Passing a capturing Swift Closure (a closure that references data from the scope) to C
	will not work. Instead, many C APIs that make use of functions as arguments (function pointers)
	allow for arbitrary data to be attached and passed to every invocation of the function pointer.
	This can be used to interface Swift closures to these function pointers by
	wrapping a closure into a object, whose pointer can be passed as an extra argument
	to C alongside a Swift closure (which gets converted to a C function and passed the pointer to).

	The Swift Closure can then convert the pointer back to a Closure-object and call the original closure,
	allowing the captured values to be used.

	Example:
	```c
	typedef void* user_data;
	void callLater(int seconds, void (*callback)(int, user_data), user_data data);
	```

	can be called like
	```swift
	var closures = [Closure<(Int)->Void>]() // Used to keep the closure alive while we passed the pointer to it to C

	let value = 2

	let wrappedClosure = Closure<(Int)->Void> { elapsed in
		print("This function was executed after \(elapsed) seconds. But still, we can read data the closure captured: value=\(value)")
	}
	closures.append(wrappedClosure) // Save the object

	callLater(
		5,
		{ elapsed, userData in
			let wrappedClosure = Closure<(Int)->Void>.fromOpaque(userData)
			wrappedClosure.closure(elapsed)
		},
		wrappedClosure.toOpaque())
	```
*/
public final class Closure<Function> {
	public let closure: Function

	public init(closure: Function) {
		self.closure = closure
	}

	/** Returns a unretained raw pointer to the closure instance.

		The caller is responsible for keeping the Closure instance alive
		e.g. by saving a reference to the object in a list.
		Closure can be retrieved with `Closure.fromOpaque()`
	*/
	public func toOpaque() -> UnsafeMutableRawPointer {
		Unmanaged.passUnretained(self).toOpaque()
	}

	/** Retrives a Closure object from a pointer previously obtained by `Closure.toOpaque()`
	*/
	public static func fromOpaque(_ pointer: UnsafeMutableRawPointer) -> Self {
		Unmanaged<Self>.fromOpaque(pointer).takeUnretainedValue()
	}
}


