import std.stdio;
import std.bigint;
import std.concurrency;

const CORES = 2;
const STEPS = 8;

void job(int index)
{
    BigInt START = 0;
    BigInt FIN = 0;
    bool stop = false;
    while (!stop)
    {
        // getting range for calculating
        receive(
            (BigInt s, BigInt e) {
                writeln(index, " got new range: ", s, ":", e-1);
                START = s;
                FIN = e;
            },
            (Variant _) { stop = true; }
            );
        // processing range of numbers
        // ...
        // ...
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
