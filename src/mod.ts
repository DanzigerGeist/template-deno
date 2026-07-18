/**
 * Returns the sum of all numbers in `values`.
 *
 * @example Sum a list of numbers
 * ```ts
 * import { sum } from "@danzigergeist/template-deno";
 * import { assertEquals } from "@std/assert";
 *
 * assertEquals(sum([1, 2, 3, 4]), 10);
 * ```
 */
export function sum(values: readonly number[]): number {
  let total = 0;
  for (const value of values) {
    total += value;
  }

  return total;
}

/**
 * Returns the arithmetic mean of `values`.
 *
 * @throws {Error} When `values` is empty.
 *
 * @example Average a list of numbers
 * ```ts
 * import { average } from "@danzigergeist/template-deno";
 * import { assertEquals } from "@std/assert";
 *
 * assertEquals(average([2, 4, 6, 8]), 5);
 * ```
 */
export function average(values: readonly number[]): number {
  if (values.length === 0) {
    throw new Error("Cannot compute average of an empty array.");
  }

  return sum(values) / values.length;
}
