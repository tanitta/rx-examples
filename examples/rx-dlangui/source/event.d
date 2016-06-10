module event;

import rx;
import dlangui.core.signals;

auto asObservable(T)(ref T signal)
if (is(T == Signal!U, U) && is(U == interface))
{
	static if (is(T == Signal!U, U))
	{
		import std.traits;
		alias return_t = ReturnType!(__traits(getMember, U, __traits(allMembers, U)[0]));
		alias param_t = ParameterTypeTuple!(__traits(getMember, U, __traits(allMembers, U)[0]));
		static assert(param_t.length == 1);
	}

	static struct LocalObservable
	{
		alias ElementType = param_t[0];
		this(ref T signal)
		{
			_subscribe = (Observer!ElementType o) {
				auto dg = (ElementType w) {
					o.put(w);
					static if (is(return_t == bool))
					{
						return true;
					}
				};

				signal.connect(dg);

				return new AnonymouseDisposable({
					signal.disconnect(dg);
				});
			};
		}

		auto subscribe(U)(U observer)
		{
			return _subscribe(observerObject!ElementType(observer));
		}

		Disposable delegate(Observer!ElementType) _subscribe;
	}

	return LocalObservable(signal);
}

class AnonymouseDisposable : Disposable
{
public:
	this(void delegate() dg)
	{
		_dispose = dg;
	}
public:
	void dispose()
	{
        if (_dispose) _dispose();
        _dispose = null;
	}

private:
	void delegate() _dispose;
}
