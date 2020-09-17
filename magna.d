import std.stdio;
import std.bitmanip;
import std.random;
import std.bigint;
import std.concurrency;

const CORES = 2;
const STEPS = 2;

void job(int index)
{
    uint urandom()
    {
        auto f = File("/dev/urandom", "r");
        scope(exit) f.close();

        auto buf = f.rawRead(new ubyte[4]);
        return buf.read!uint();
    }
    // Input: n is always > 2 and odd
    // easy probably prime based on Miller-Rabin
    // works on n > 1024
    bool isPrime(in BigInt n)
    {
        if (n > 2 && !(n & 1))
        {
            return false;
        }

    	BigInt d = n - 1;
    	ulong s = 0;
    	while(!(d & 1))
    	{
    		d /= 2;
    		s++;
    	}

    	outer:
    	foreach (immutable _; 0..8)
    	{
    		ulong a = uniform(2, 1024);
    		BigInt b = n / a;
    		BigInt x = powmod(b, d, n);
    		if (x == 1 || x == n - 1)
    			continue;
    		foreach (immutable __; 1 .. s)
    		{
    			x = powmod(x, BigInt(2), n);
    			if (x == 1)
    				return false;
    			if (x == n - 1)
    				continue outer;
    		}
    		return false;
    	}
    	return true;
    }
    bool isMagna(in BigInt n)
    {
        BigInt p = 10;
        while (n >= p)
        {
            auto q = n / p;
            auto r = n % p;
            if(!isPrime(q + r))
            {
                return false;
            }
            p *= 10;
        }
        return true;
    }


	auto rnd = Random(urandom());

    BigInt START = 0;
    BigInt FIN = 0;
    bool stop = false;


    while (!stop)
    {
        // getting range for calculating
        receive(
            (BigInt s, BigInt e)
            {
                writeln(index, " got new range: ", s, ":", e);
                START = s;
                FIN = e;
            },
            (Variant _)
            {
                stop = true;
            });
        writeln(START, ":", FIN);
        // processing range of numbers
        /*
        for (BigInt i = START; i < FIN; i++)
        {
            writeln(index,":", i);

            if(isMagna(i))
            {
                writeln("!:", i);
            }
        }
        */
        writeln(isMagna(BigInt(22061)));


        //done, send me next
        ownerTid.send(thisTid, true);
    }
}


void main()
{
    Tid[CORES] w;
    BigInt START = 1000;
    BigInt INCR  = 1000;

    // create
    for (int i = 0; i < w.length; i++)
    {
        auto next = START+INCR;
        w[i] = spawn(&job, i);
        w[i].send(START, next);
        START = next;
    }

    // feed numbers
    for (int i = 0; i < STEPS; i++)
    {
        receive(
            (Tid sender, bool _)
            {
                auto next = START+INCR;
                sender.send(START, next);
                START = next;
            });
    }

    // stop all workers
    for (uint i = 0; i < w.length; i++)
    {
        w[i].send(true);
    }

}
