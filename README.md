# 6502 EhBASIC

**Derived from EhBASIC**

This is [Lee Davison's EhBASIC](http://6502.org/users/mycorner/6502/ehbasic/index.html) version 2.22 with a minimal set of modifications that allow it to be compiled with the [cc65](https://cc65.github.io/) assembler.

## Usage

Prerequisites:
* [cc65](https://cc65.github.io/) tools
* [minipro](https://davidgriffith.gitlab.io/minipro/) EEPROM tool (optional)

To build the ROM image:

```
make
```

To write the ROM image to an EEPROM:

```
make upload
```

## Customization

It should be possible to get up and running by mainly customizing the addresses in `main.s` and `memory.cfg`. The current settings are based on my SBC, which has the same address decoding configuration as [Daryl Rictor's SBC-2](https://sbc.rictor.org/info2.html).

## Changes to the original

[Here is a diff between the original code and the modifications](https://github.com/jfredrickson/ehbasic-cc65/compare/5f05da0...main).

* Replace program counter assignments (`*=`) with ca65 `.segment` commands.
* Access a real ACIA in the example monitor, not a simulated one
* Configure ACIA addressing in `main.s`
* Configure RAM_BASE and RAM_TOP in `main.s` (leaves room for the zero page, stack, and the `$0200` page that EhBASIC uses)
