# Leveraging ETS Effectively

This repository contains sample code for the talk [*Leveraging ETS Effectively,*](https://speakerdeck.com/evadne/leveraging-ets-effectively) presented at [ElixirConf EU 2019](http://www.elixirconf.eu) on 9 April 2019.

## Running the Code

To run the code:

1. Clone the repository
2. Run `mix deps.get`
3. Run `iex -S mix`
4. Run one of the following Scenarios: `<module>.run`.

## Scenarios

The Scenarios included in this repository are:

1.  **Playground.Scenario.Agent**

    Use an Agent which holds a Map with integer keys.

    Tasks:

    - Bulk Load of `count` items
    - Concurrent Load of `count` items
    - Sequential Read of `count` items
    - Randomised Read of `count` items
    - Sequential Update of `count` items, incrementing the integer

2.  **Playground.Scenario.ETS**

    Use an ETS table.

    Tasks:

    - Bulk Load of `count` items (in one go)
    - Concurrent Load of `count` items
    - Sequential Read of `count` items
    - Randomised Read of `count` items
    - Sequential Update Counter
    - Sequential Update Element
    - Sequential Lookup Element + Update Element


3.	**Playground.Scenario.Data**

    Read constants from Module.

    Tasks:

    - Build Module with `count` items, based on List
    - Sequential Read of `count` items
    - Randomised Read of `count` items
    - Build Module with `count` items, based on Map
    - Sequential Read of `count` items
    - Randomised Read of `count` items

4.  **Playground.Scenario.Counters.One**

    Comparison of Counters in ETS vs Atomics

    Tasks:

    - Sequentially update an ETS counter `count` times
    - Sequentially update an 1-arity atomics `count` times
    - Concurrently update an ETS counter `count` times
    - Concurrently update an 1-arity atomics `count` times
    - Concurrently get an ETS counter `count` times
    - Concurrently get an 1-arity atomics `count` times

5.  **Playground.Scenario.Counters.Many**

    Comparison of Counters in ETS vs Atomics

    Tasks:

    - Sequentially update `count` ETS counters
    - Sequentially update a `count`-arity atomics
    - Concurrently update `count` ETS counters
    - Concurrently update a `count`-arity atomics
    - Concurrently get `count` ETS counters
    - Concurrently get `count` ETS counters again
    - Concurrently get `count`-arity atomics
    - Concurrently get `count`-arity atomics again

6.  **Playground.Scenario.Counters.Many.Atomics.One**

    Deeper Comparison of various Atomics access patterns

    Tasks:

    - Sequentially update a `count`-arity atomics (sequential, ordered)
    - Sequentially update a `count`-arity atomics (sequential, randomised)
    - Concurrently update a `count`-arity atomics (concurrent, sequential, unordered tasks)
    - Concurrently update a `count`-arity atomics (concurrent, sequential, ordered tasks)
    - Concurrently update a `count`-arity atomics (concurrent, randomised, unordered tasks)
    - Concurrently update a `count`-arity atomics (concurrent, randomised, ordered tasks)


7.  Playground.Scenario.Counters.Many.Atomics.Many

    Deeper Comparison of various Atomics access patterns

    Tasks:

    - Sequentially update `count` 1-arity atomics (sequential, ordered)
    - Sequentially update `count` 1-arity atomics (sequential, randomised)
    - Concurrently update `count` 1-arity atomics (concurrent, sequential, unordered tasks)
    - Concurrently update `count` 1-arity atomics (concurrent, sequential, ordered tasks)
    - Concurrently update `count` 1-arity atomics (concurrent, randomised, unordered tasks)
    - Concurrently update `count` 1-arity atomics (concurrent, randomised, ordered tasks)

8.  **Playground.Scenario.Northwind**

    ETS backed Ecto interactions with Northwind Database as an example.

    Scenarios:

    - List all Employees
    - Insert / Delete Employee
    - Ingestion from JSON file
    - Select with Bound ID
    - Where
    - Select Where
    - Select / Update
    - Assoc Traversal
    - Promote to Customer
    - Stream Employees
    - Order / Shipper / Orders Preloading

## Licensing & Legal Matters

Contents of this repository is under MIT license, except that you are not to publish the ETS adapter under `Playground.Repository` to Hex. This is because I would like to do so in the near future.

This project contains a copy of data obtained from the Northwind database, which is owned by Microsoft. It is included for demonstration purposes only.

## Acknowledgements

Special thanks to:

- Mr Jay Nelson, for the excellent [Erlang Patterns of Concurrency](https://github.com/duomark/epocxy) which served as inspiration for this talk.

- Mr Francesco Cesarini, for suggesting a deeper look into the performance characteristics of Atomics vs ETS-based counters.

## References

Further Reference Materials can be found within the [Deck](https://speakerdeck.com/evadne/leveraging-ets-effectively).
