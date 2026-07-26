import { average, sum } from "../src/mod.ts";

const numbers = Array.from({ length: 1_000 }, (_, index) => index);

Deno.bench("sum 1k numbers", { group: "aggregate", baseline: true }, () => {
  sum(numbers);
});

Deno.bench("average 1k numbers", { group: "aggregate" }, () => {
  average(numbers);
});
