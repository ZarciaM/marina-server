# marina
Yet another SAT solver in Ocaml, _marina_ being the Malagasy word for _True_.

## Practical example

_Marina ve fa misy ny zazavavindrano?_
Is it true that Zazavavindrano (mermaids) exist?
The following assumptions were gathered across the Malagasy folklore:
* Zazavavindrano who don't swim in warm sea have red stripes
* Zazavavindrano either have blue stripes or does not have red stripes
* Zazavavindrano who live in the corals don't eat shrimps
* A zazavavindrano eats shrimps if and only if she swims in warm sea
* Zazavavindrano who have blue stripes swim in warm sea and live in the corals
* Zazavavindrano who swim in warm sea have blue stripes

```
$ ./marina 'zazavavindrano & zazavavindrano -> 
          ( (~ swim_warm -> red)
          & (blue | ~ red)
          & (live_corals -> ~ eat_shrimps)
          & (eat_shrimps <-> swim_warm)
          & (blue -> (swim_warm & live_corals))
          & (swim_warm -> blue) )'
> (,false)
```

## Syntax

Invoke `./marina '<prop>'` such that `<prop>` is
in the following Backus Normal Form:
```
<prop> ::=  T
          | F
          | <atom>
          | ~ <prop>
          | <prop> & <prop>
          | <prop> | <prop>
          | <prop> -> <prop>
          | <prop> <-> <prop>
          | (<prop>)
<atom> ::= ^[a-z_]+[0-9]*$
```
## Installation

### Ocaml dependencies

```
$ apt install ocaml opam
$ opam install ocamlfind ounit2
```

Depending on you Operating System, the installation of `ocaml` and `opam` might differ:
see https://ocaml.org/docs/install.html.
The CI executes tests for MacOS and Ubuntu.

### Building marina
```
$ make
$ ./marina '(a&b | c)->d  <->  ~e'
(a,true) (b,true) (d,true) (e,false)
```

Notice that provided assignement is _partial_:
value of `c` has no effect on the satisfiability of the whole proposition.

## Acknowledgment

Underlying decision procedure is based on IF-expression normalization:
https://usr.lmf.cnrs.fr/~jcf/ftp/tp-info/IFexpressions.pdf
