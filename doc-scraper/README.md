# doc-scraper

This is a simple JS script that loads the latest Playdate C SDK documentation HTML, extracts the function names and descriptions, and injects them into the Zig C bindings file for nice auto-completion in IDEs.

I used Bun and TypeScript for simplicity, but the same code probably works with just Node.js and something like TSX for running the TypeScript code.

## Setup

1. Install Bun - https://bun.sh/docs/installation
1. Install dependencies - `bun install`

## Development

- Run - `bun scrape`
- Lint when done - `bun lint`

## Overview for non-JS devs

People interested in this might not be familiar with the JavaScript ecosystem, so here's a quick overview of the tools used.

Bun is a JavaScript runtime and toolchain that can also run code written in TypeScript without any extra steps. TypeScript is a superset of JavaScript that adds types and other features for less error-prone code. The annoying thing about all JS projects is the amount of configuration files you just have to know to get right.

- package.json - Tells Bun what the project is, what dependencies it needs, and what helpful scripts are available.
- tsconfig.json - Tells TypeScript how to compile the TS code into plain JS.
- biome.json - Configuration for the (optional) linter on what rules to enforce.
- bun.lockb - A lockfile that tells Bun what versions of dependencies were last fetched. Makes it possible to share the same versions of deps between multiple machines.

The `bun install` command resolves the dependencies in package.json and downloads them to the `node_modules` directory. They are then magically available for importing in code.
